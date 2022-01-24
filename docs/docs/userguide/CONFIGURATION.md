# Configuration

In order to provision the infrastructure and install an Atlassian Data Center product, you need to create a valid Terraform configuration.
All configuration data should go to a terraform variable file.

The content of the configuration file is divided into two groups:

1. [Mandatory configuration](#mandatory-configuration)
2. [Optional configuration](#optional-configuration)


!!! info "Configuration file format."
    The configuration file is an ASCII text file with the `.tfvars` extension.
    The config file must contain all mandatory configuration items with valid values.
    If any optional items are missing, the default values will be applied.
   
The mandatory configuration items are those you should define once before the first installation. Mandatory values cannot be changed in the entire environment lifecycle.

The optional configuration items are not required for installation by default. Optional values may change at any point in the environment lifecycle.
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

## Mandatory configuration

### Environment name

`environment_name` provides your environment a unique name within a single cloud provider account.
This value cannot be altered after the configuration has been applied.
The value will be used to form the name of some resources including `vpc` and `Kubernetes cluster`.

```terraform
environment_name = "<YOUR-ENVIRONMENT-NAME>"
```

Environment names should start with a letter and can contain letters, numbers, and dashes (`-`).

The maximum value length is 25 characters.


### Region

`region` defines the cloud provider region that the environment will be deployed to.

The value must be a valid [AWS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html){.external}.

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

!!!info "Restoring from existing dataset"
    If the [`dataset_url` variable](#restoring-from-backup) is provided, the _Bamboo System Admin Credentials_ properties are ignored.
    You will need to use user credentials from the dataset to log into the instance.


## Optional configuration

### Restoring from backup
To restore data from an existing [Bamboo backup](https://confluence.atlassian.com/bamboo/exporting-data-for-backup-289277255.html){.external},
you can set the `dataset_url` variable to a publicly accessible URL where the dataset can be downloaded.

```terraform
dataset_url = "https://bamboo-test-datasets.s3.amazonaws.com/dcapt-bamboo-no-agents.zip"
```

This dataset is downloaded to the shared home and then imported by the Bamboo instance. To log in to the instance,
you will need to use any credentials from the dataset. 

!!!info "Provisioning time"
    Restoring from the dataset will increase the time it takes to create the environment.

### Resource tags

`resource_tags` are custom metadata for all resources in the environment. You can provide multiple tags as a list. 

Tag names must be unique.

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
    
### Cluster instance type

`instance_types` provides the instance types for the Kubernetes cluster node group.

```terraform
instance_types = ["instance-type"]  # e.g: ["m5.2xlarge"]
```

If an `instance_types` value is not defined in the configuration file, the default value of `m5.4xlarge` is used.

The instance type must be a valid [AWS instance type](https://aws.amazon.com/ec2/instance-types/){.external}.

!!! warning "You cannot change this value after the infrastructure is provisioned."

### Cluster size

`desired_capacity` provides the desired number of nodes that the node group should launch with initially.

* The default value for the number of nodes in Kubernetes node groups is `2`.
* Minimum is `1` and maximum is `10`.
* This value cannot be changed after the infrastructure is provisioned. 

```terraform
desired_capacity = <number-of-nodes>  # between 1 and 10
```

### Domain name

We recommend using a domain name to access the application via HTTPS. You will be required to secure a domain name and supply the configuration to the config file.

When the domain is provided, Terraform will create a [Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) hosted zone based on the `environment` name.

```terraform
domain="<domain-name>" # for example: "mydomain.com"
```

A fully qualified domain name uses the following format: `<product>.<environment-name>.<domain-name>`. For example `bamboo.staging.mydomain.com`.

!!! warning "Removing domain from deployment"
    Removing the domain name to revert to an insecure connection is not possible after the environment has been deployed (see below).

!!! tip "Ingress controller"
    If a domain name is defined, Terraform will create a [nginx-ingress controller](https://kubernetes.github.io/ingress-nginx/) in the EKS cluster that will provide access to the application via the domain name.
    
    Terraform will also create an [ACM certificate](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) to provide secure connections over HTTPS.

#### Provisioning without a domain name

You can provision the infrastructure without a domain name by commenting out the `domain` variable in the `.tfvars` file.

In that case, the application will run unsecured on an elastic load balancer domain: `http://<load-balancer-id>.<region>.elb.amazonaws.com`.

The final URL is printed out as part of the outputs after the infrastructure has been provisioned.

### Database Instance Class

`db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.

```terraform
db_instance_class = "<instance.class>"  # e.g. "db.t3.micro"
```

### Database allocated storage

`db_allocated_storage` sets the allocated storage for the database instance in GiB.
  
```terraform
db_allocated_storage = 100 
```

!!! info "The allowed value range of allocated storage may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Database IOPS

`db_iops` sets the requested number of I/O operations per second that the DB instance can support.

```terraform
db_iops = 1000
```

!!! info "The allowed value range of IOPS may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Number of Bamboo agents

`number_of_bamboo_agents` sets the number of remote agents to be launched. To disable agents, set this value to `0`.

```terraform
number_of_bamboo_agents = 5
```

!!! info "The number of agents is limited to the number of allowed agents in your license."
    Any agents beyond the allowed number won't be able to join the cluster.

!!! warning "A valid license is required to install bamboo agents"
    Bamboo needs a valid license to install remote agents. Disable agents if you don't provide a license at installation time.
    
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
