# Common configuration

In order to provision the infrastructure and install an Atlassian Data Center product, you need to create a valid [Terraform configuration](https://www.terraform.io/language){.external}. All configuration data should go to a Terraform configuration file.

The content of the configuration file is divided into two groups:

1. [Common configuration](#common-configuration)
2. [Product specific configuration](#product-specific-configuration)

!!! info "Configuration file format."
    The configuration file is an ASCII text file with the `.tfvars` extension.
    The config file must contain all mandatory configuration items with valid values.
    If any optional items are missing, the default values will be applied.

The [mandatory configuration](#mandatory-configuration) items are those you should define once before the first installation. Mandatory values cannot be changed during the entire environment lifecycle.

The [optional configuration](#optional-configuration) items are not required for installation by default. Optional values may change at any point in the environment lifecycle.
Terraform will retain the latest state of the environment and keep track of any configuration changes made later.

The following is an example of a valid configuration file:

``` terraform
# Mandatory items
environment_name = "my-bamboo-env"
region           = "us-east-2"

# Optional items
resource_tags = {
  Terraform    = "true",
  Organization = "atlassian",
  product      = "bamboo" ,
}

instance_types   = ["m5.xlarge"]
desired_capacity = 2
domain           = "mydomain.com"
```

## Common Configuration

Environmental properties common to all deployments.

### Environment Name

`environment_name` provides your environment a unique name within a single cloud provider account. This value cannot be altered after the configuration has been applied. The value will be used to form the name of some resources including `VPC` and `Kubernetes cluster`.

```terraform
environment_name = "<your-environment-name>" # e.g. "my-terraform-env"
```

!!! info "Format"

    Environment names should start with a letter and can contain letters, numbers, and dashes (`-`). The maximum value length is 24 characters.

### EKS K8S API version

`eks_version` is the supported EKS K8S API version. It must be a valid [EKS version](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html).
!!! tip "Latest EKS version"

  It is recommended to use the default value, however it is possible to override it to try a different (the latest) EKS version for experimental purposes.

### Region

`region` defines the cloud provider region that the environment will be deployed to.

```terraform
region = "<REGION>"  # e.g. "ap-northeast-2"
```

!!! info "Format"

    The value must be a valid [AWS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html){.external}.

### Products

The `products` list can be configured with one or multiple products. This will result in these products being deployed to the same K8s cluster. For example, if a Jira and Confluence deployment is required this property can be configured as follows:

```terraform
products = ["jira", "confluence"]
```

!!! info "Available values"

    `jira`, `confluence`, `bitbucket`, `bamboo`

### Whitelist IP blocks

`whitelist_cidr` defines a set of CIDRs that are allowed to run the applications.

By default, the deployed applications are publicly accessible. You can restrict this access by changing the default value to your desired CIDR blocks that are allowed to run the applications.

```terraform
whitelist_cidr = ["199.0.0.0/8", "119.81.0.0/16"]
```

### Domain

We recommend using a domain name to access the application via `HTTPS`. You will be required to secure a domain name and supply the configuration to the config file.

When the domain is provided, Terraform will create a [Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) hosted zone based on the `environment` name.

```terraform
domain="<DOMAIN_NAME>" # e.g. "mydomain.com"
```

A fully qualified domain name uses the following format: `<product>.<environment-name>.<domain-name>`. For example `bamboo.staging.mydomain.com`.

!!! tip "Ingress controller"

    If a domain name is defined, Terraform will create a [nginx-ingress controller](https://kubernetes.github.io/ingress-nginx/) in the EKS cluster that will provide access to the application via the domain name.

    Terraform will also create an [ACM certificate](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) to provide secure connections over HTTPS.

!!! info "Provision the infrastructure without a domain"

    When commented out the product will be exposed via an unsecured (`HTTP` only) DNS endpoint automatically provisioned as part of the AWS ELB load balancer, for example: `http://<load-balancer-id>.<region>.elb.amazonaws.com`. This DNS Name will be printed out as part of the outputs after the infrastructure has been provisioned.

### Resource tags

`resource_tags` are custom metadata for all resources in the environment. You can provide multiple tags as a list.

!!! info "Tag propagation"

    Tag names must be unique, and tags will be propogated to all provisioned resources.

```terraform
resource_tags = {
  <tag-name-0> = "<tag-value>",
  <tag-name-1> = "<tag-value>",
  ...
  <tag-name-n> = "<tag-value>",
}
```

!!! warning "Using Terraform CLI to apply tags is not recommended and may lead to missing tags in some resources."

    To apply tags to all resources, follow the [installation guide](../INSTALLATION.md).

### EKS instance type and storage size

`instance_types` defines the instance type for the EKS cluster node group.

```terraform
instance_types = ["m5.2xlarge"]
```

The instance type must be a valid [AWS instance type](https://aws.amazon.com/ec2/instance-types/){.external}.

`instance_disk_size` defines the size of default storage attached to an instance.

```terraform
instance_disk_size = 50
```

!!! warning "Instance type and disk size selection"

    Both properties cannot be changed once the infrastructure has been provisioned.

### EKS Node Launch Template

When Terraform creates a node group for the EKS cluster, the default launch template is created behind the scenes. However, if you need to install any additional tooling/software in the worker node EC2 instances, you may provide your own template in `data-center-terraform/modules/AWS/eks/nodegroup_launch_template/templates`.
This needs to be a file with `.tlp` extension. See: [Amazon EC2 user data](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data). Here's an example:

```
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
echo "Running custom user data script"

--==MYBOUNDARY==--
```
Templates in `data-center-terraform/modules/AWS/eks/nodegroup_launch_template/templates` will be merged with the default launch template.
If you need to use environment variables in your custom scripts, make sure you escape them with an additional dollar sign, otherwise `templatefile` function will complain about a missing env var:

```
foo="bar"
echo $${foo}
```
Environment variables passed to `templatefile` function are not configurable (defined in `data-center-terraform/modules/AWS/eks/nodegroup_launch_template/locals.tf`), thus
it makes sense to generate template outside terraform and pull it before installing/upgrading.

### Cluster size

EKS cluster creates an [Autoscaling Group (ASG)](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html)
that has defined minimum and maximum capacity. You are able to set these values in the config file:

* Minimum values are `1` and maximum is `20`.

```terraform
min_cluster_capacity = 1  # between 1 and 20
max_cluster_capacity = 5  # between 1 and 20
```

!!! tip "Cluster size and cost"

    In the installation process, [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
    is installed in the Kubernetes cluster. The number of nodes will be automatically adjusted depending on the workload
    resource requirements.

### Additional IAM roles

When the EKS cluster is created, only the entity that created the cluster can access and list
resources inside the cluster. To enable access for additional roles, you can add them to the config file:

```terraform
eks_additional_roles = [
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
    username = "ROLE_NAME"
    groups = [
      "system:masters"
    ]
  }
]
```

!!! info "Permissions in AWS EKS"

    For additional information regarding the authorisation in EKS cluster, follow the official
    [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html){.external}.

### Logging S3 bucket name

If you wish to log activities of terraform backend create S3 bucket and provide the name of the S3 bucket as follows. This will allow the terraform script to link your terraform backend to logging bucket.

```terraform
logging_bucket = <LOGGING_S3_BUCKET_NAME>  # default is null
```

!!! warning "S3 Logging bucket Creation"

    Providing `logging_bucket` will not guarantee the creation of the S3 Bucket. You will need to create one as part of the prerequisites.


### Monitoring

If you want to deploy a monitoring stack to the cluster, use the following variable in config.tfvars file:

```
monitoring_enabled = true
```

When enabled, Terraform will deploy [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack){.external} Helm chart
with Prometheus, AlertManager, Node Exporter and Grafana.

By default, Grafana service isn't exposed, and you can login to Grafana at `http://localhost:3000` after running:

```
kubectl port-forward $grafana-pod 3000:3000 -n kube-monitoring
```

If you want to expose Grafana service, set `monitoring_grafana_expose_lb` to `true`:

```
monitoring_grafana_expose_lb = true
```

Run the following command to get Grafana service hostname:

```
kubectl get svc -n kube-monitoring
```

Out of the box Grafana is shipped with a dozen of Kubernetes dashboards which you can use to monitor pods health. You can also create own custom configmaps labeled `grafana_dashboard=dc_monitoring`, and Grafana sidecar will automatically import them.

## Product specific configuration

=== "Bamboo"

    [Bamboo specific configuration](BAMBOO_CONFIGURATION.md)

=== "Confluence"

    [Confluence specific configuration](CONFLUENCE_CONFIGURATION.md)

=== "Jira"

    [Jira specific configuration](JIRA_CONFIGURATION.md)



## Sensitive Data

Sensitive input data will eventually be stored as [secrets within Kubernetes cluster](https://kubernetes.io/docs/concepts/configuration/secret/#security-properties).

We use `config.tfvars` file to pass configuration values to Terraform stack.
The file itself is plain-text on local machine, and will not be stored in remote backend
where all the Terraform state files will be stored encrypted.
More info regarding sensitive data in Terraform state can be found [here](https://www.terraform.io/docs/language/state/sensitive-data.html).

To avoid storing sensitive data in a plain-text file like `config.tfvars`, we recommend storing them in environment variables
prefixed with [`TF_VAR_`](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name).

Take`bamboo_admin_password` for example, for Linux-like sytems, run the following command to write bamboo admin password to environment variable:

```shell
export TF_VAR_bamboo_admin_password=<password>
```

If storing this data as plain-text is not a particular concern for the environment to be deployed, you can also choose to supply the values in `config.tfvars` file. Uncomment the corresponding line and configure the value there.
