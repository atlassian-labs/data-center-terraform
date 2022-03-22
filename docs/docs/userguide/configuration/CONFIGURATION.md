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


### Region

`region` defines the cloud provider region that the environment will be deployed to.

```terraform
region = "<REGION>"  # e.g. "ap-northeast-2"
```

!!! info "Format"

    The value must be a valid [AWS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html){.external}.

### Products

The `products` list can be configured with one or many products. This will result in these products being deployed to the same K8s cluster. For example, if a Jira and Confluence deployment is required this property can be configured as follows:

```terraform
products = ["jira", "confluence"]
```

!!! info "Product specific infrastructure"

    All of the appropriate infrastructure for the product selection will be stood up by Terraform.

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

    To apply tags to all resources, follow the [installation guide](INSTALLATION.md).

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

### Major RDS version upgrade

The `major_rds_version_upgrade` property can be set to `true` to enable major RDS version upgrades. 
To upgrade the RDS you need to define the major version for the specific product in the product configuration section as well.  

```terraform
major_rds_version_upgrade = true  # default is false
```

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
