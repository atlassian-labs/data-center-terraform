# Configuration

In order to create the infrastructure and install the product you need to configure the terraform project.
All configuration data should go to a terraform variable file.


The content of the config file is divided into two groups:

1. [Mandatory configuration](#mandatory-configuration)
2. [Optional configuration](#optional-configuration)


!!! info "Configuration file format."
    The config file is an ASCII text file with `.tfvars` extension.
    The config file should contain all mandatory configuration items with valid values.
    Optional items can be part of the content. If any optional item is missing, the default value will be applied.
   
The mandatory configuration items are those you should define once before the first installation, and you cannot change them in the entire environment lifecycle.

However, the optional configuration part applies to those items that are not required for installation by default, but you can define and override the default value.
The optional configuration may change anytime in the life cycle of the environment.
Terraform will keep the latest status of the environment and use it for any further change you make later.

!!! info "An example of config file for terraform project:"
    Here is a sample of a configuration file for the project.
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

## Mandatory configuration

### Environment Name
`environment_name` provides your environment a unique name within a single cloud provider account.
This value cannot be altered after the configuration has been applied.
The value will be used to form the name of some resources including `vpc` and `Kubernetes cluster`.
```terraform
environment_name = "<YOUR-ENVIRONMENT-NAME>"
```
Environment names should start with an alphabet character and could contain alphabet, numbers and dash `-`.
The length of the `environment_name` value cannot exceed 25 characters.


### Region
`region` defines the cloud provider region that this configuration will deploy to.
This value should be a valid [AWS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html){.external}.


```terraform
region = "<Region>"  # e.g: "ap-northeast-2"
```


### Bamboo License
`bamboo_license` takes the license key of Bamboo product.
Make sure that there is no new lines or spaces in license key.

```terraform
bamboo_license = "<license key>"
```

!!!warning "Sensitive data"

    `bamboo_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](#sensitive-data) section.


### Bamboo System Admin Credentials
Four values are required to configure Bamboo system admin credentials.

```terraform
bamboo_admin_username = "<username>"
bamboo_admin_password = "<password>"
bamboo_admin_display_name = "<display name>"
bamboo_admin_email_address = "<email address>"
```

!!!warning "Sensitive data"

    `bamboo_admin_password` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended.

    Please refer to [Sensitive Data](#sensitive-data) section.


## Optional configuration

### Resource Tags
`resource_tags` are the custom tags for all resources to be created in the environment. Tag names should be unique.
You can add all tags you need to propagate among the resources as a list. Resource tags are optional.

```terraform
resource_tags = {
  <tag-name-0> = "<tag-value>",
  <tag-name-1> = "<tag-value>",
  ...
  <tag-name-n> = "<tag-value>",
}
```
* Note: In order to apply tags to all resources, you must follow the recommended [installation guide](INSTALLATION.md). Using `terraform CLI` is not recommended and may leads to missing tags in some resources.

### Cluster Instance Type
`instance_types` provides the instance types for the Kubernetes cluster node group.

* The default value for this will be `m5.4xlarge` if it is not defined in the config file.
* Instance type should be a valid [AWS instance type](https://aws.amazon.com/ec2/instance-types/){.external}.
* This value cannot be changed after the infrastructure is provisioned. 

```terraform
instance_types = ["instance-type"]  # e.g: ["m5.2xlarge"]
```

### Cluster Size
`desired_capacity` provides the desired number of nodes that the node group should launch with initially.

* The default value for the number of nodes in Kubernetes node groups is `2`.
* Minimum is `1` and maximum is `10`.
* This value cannot be changed after the infrastructure is provisioned. 

```terraform
desired_capacity = <number-of-nodes>  # between 1 and 10
```

### Domain Name
It is highly recommended to use a domain name and access the application via HTTPS protocol. You will be required
to secure a domain name and supply the configuration to the config file. When the domain is provided, Terraform will 
create a [Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) hosted zone based on the `environment` name.

```terraform
domain="<domain-name>" # for example: "mydomain.com"
```

Final domain will have the following format: `<product>.<environment-name>.<domain-name>`. For example `bamboo.staging.mydomain.com`.

!!! warning "Removing domain from deployment"

    If you have deployed with domain, you cannot remove the domain later from the deployment to revert
    to an unsecured deployment running on HTTP (see below).

??? tip "Ingress Controller"
    When the domain is used, Terraform will create [nginx-ingress controller](https://kubernetes.github.io/ingress-nginx/) 
    in the EKS cluster that will provide access to the application via the domain name.
    It also creates an [ACM certificate](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) that is 
    ensuring access over secure HTTPS protocol.

#### Provisioning without domain name

You can provision the infrastructure without a domain name. To do that, you can comment out the `domain` variable in the `tfvars` file.

In that case the application will run unsecured on an elastic load balancer domain:
`http://<load-balancer-id>.<region>.elb.amazonaws.com`.
The final URL is printed out as part of the outputs after the infrastructure is provisioned.

### Database Instance Class
`db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by
planned workload of the DB instance. Detailed available instance classes can be found via 
[AWS RDS documentation on DB Instance Class](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.

```terraform
db_instance_class = "<instance.class>"  # e.g. "db.t3.micro"
```

### Database Allocated Storage
`db_allocated_storage` sets the allocated storage for database instance in GiB.

* Note: the allowed value range of allocated storage may vary based on instance class. 
  You may want to adjust these values according to your needs. Documentation can be found via:
  [AWS RDS documentation on Storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.
  
```terraform
db_allocated_storage = 100 
```

### Database IOPS
`db_iops` sets the requested number of I/O operations per second that the DB instance can support.

* Note: the allowed value range of IOPS may vary based on instance class.
  You may want to adjust these values according to your needs. Documentation can be found via:
  [AWS RDS documentation on Storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

```terraform
db_iops = 1000
```

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

If storing these data as plain-text is not a particular concern for the environment to be deployed, 
you can also choose to supply the values in `config.tfvars` file.
Uncomment the corresponding line and configure the value there.
