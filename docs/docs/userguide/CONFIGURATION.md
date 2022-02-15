# Configuration

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
domain="<DOMAIN NAME>" # e.g. "mydomain.com"
```

A fully qualified domain name uses the following format: `<product>.<environment-name>.<domain-name>`. For example `bamboo.staging.mydomain.com`.

!!! warning "Removing domain from deployment"

    Removing the domain name to revert to an insecure connection is not possible after the environment has been deployed (see below).

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

### EKS instance type

`instance_types` defines the instance type for the EKS cluster node group.

```terraform
instance_types = ["m5.2xlarge"]
```

The instance type must be a valid [AWS instance type](https://aws.amazon.com/ec2/instance-types/){.external}.

!!! warning "Instance type selection"

    The instance type cannot be changed once the infrastructure has been provisioned.

### EKS node count

`desired_capacity` provides the desired number of nodes that the EKS node group should launch with initially.

* The default value for the number of nodes in Kubernetes node groups is `1`.
* Minimum is `1` and maximum is `10`.

```terraform
desired_capacity = <NUMBER OF NODES>  # between 1 and 10
```

!!! warning "You cannot change this value after the infrastructure is provisioned."


## Product specific configuration

=== "Bamboo"

    ### Bamboo Helm chart version

    `bamboo_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bamboo instance.

    ```terraform
    bamboo_helm_chart_version = "1.0.0"
    ```
    
    ### Bamboo Agent Helm chart version
    
    `bamboo_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bamboo Agent instance.
    
    ```terraform
    bamboo_agent_helm_chart_version = "1.0.0"
    ```

    ### Bamboo License

    `bamboo_license` takes the license key of Bamboo product. Make sure that there is no new lines or spaces in license key.

    ```terraform
    bamboo_license = "<LICENSE KEY>"
    ```

    !!!warning "Sensitive data"

        `bamboo_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

        Please refer to [Sensitive Data](#sensitive-data) section.

    ### Bamboo System Admin Credentials

    Four values are required to configure Bamboo system admin credentials.
    
    ```terraform
    bamboo_admin_username = "<USERNAME>"
    bamboo_admin_password = "<PASSWORD>"
    bamboo_admin_display_name = "<DISPLAY NAME>"
    bamboo_admin_email_address = "<EMAIL ADDRESS>"
    ```

    !!!warning "Sensitive data"
    
        `bamboo_admin_password` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended.
    
        Please refer to [Sensitive Data](#sensitive-data) section.

    !!!info "Restoring from existing dataset"

        If the [`dataset_url` variable](#restoring-from-backup) is provided (see [Restoring from Backup](#restoring-from-backup) below), the _Bamboo System Admin Credentials_ properties are ignored.

        You will need to use user credentials from the dataset to log into the instance.
    
    ### Bamboo instance resource configuration
    
    The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Bamboo instance. (Used default values as example.)
    
    ```terraform
    bamboo_cpu = "1"
    bamboo_mem = "1Gi"
    bamboo_min_heap = "256m"
    bamboo_max_heap = "512m"
    ```
    
    ### Bamboo Agent instance resource configuration
    
    The following variables set number of CPU and amount of memory of Bamboo Agent instances. (Used default values as example.)
    
    ```terraform
    bamboo_agent_cpu = "0.25"
    bamboo_agent_mem = "256m"
    ```
    
    ### Number of Bamboo agents
    
    `number_of_bamboo_agents` sets the number of remote agents to be launched. To disable agents, set this value to `0`.
    
    ```terraform
    number_of_bamboo_agents = 5
    ```

    !!! info "The number of agents is limited to the number of allowed agents in your license."
        
        Any agents beyond the allowed number won't be able to join the cluster.
    
    !!! warning "A valid license is required to install bamboo agents"
        
        Bamboo needs a valid license to install remote agents. Disable agents if you don't provide a license at installation time.

    ### Database engine version

    `bamboo_db_major_engine_version` sets the PostgeSQL engine version that will be used.

    ```terraform
    bamboo_db_major_engine_version = "13" 
    ```

    !!! info "Supported DB versions"

        Be sure to use a [DB engine version that is supported by Bamboo](https://confluence.atlassian.com/bamboo/supported-platforms-289276764.html#Supportedplatforms-Databases){.external} 

    ### Database Instance Class

    `bamboo_db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.
    
    ```terraform
    bamboo_db_instance_class = "<INSTANCE CLASS>"  # e.g. "db.t3.micro"
    ```
    
    ### Database Allocated Storage
    
    `bamboo_db_allocated_storage` sets the allocated storage for the database instance in GiB.
    
    ```terraform
    bamboo_db_allocated_storage = 100 
    ```
    
    !!! info "The allowed value range of allocated storage may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.
    
    ### Database IOPS
    
    `bamboo_db_iops` sets the requested number of I/O operations per second that the DB instance can support.
    
    ```terraform
    bamboo_db_iops = 1000
    ```
    
    !!! info "The allowed value range of IOPS may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

    ### Restoring from Backup

    To restore data from an existing [Bamboo backup](https://confluence.atlassian.com/bamboo/exporting-data-for-backup-289277255.html){.external},
    you can set the `dataset_url` variable to a publicly accessible URL where the dataset can be downloaded.
    
    ```terraform
    dataset_url = "https://bamboo-test-datasets.s3.amazonaws.com/dcapt-bamboo-no-agents.zip"
    ```
    
    This dataset is downloaded to the shared home and then imported by the Bamboo instance. To log in to the instance,
    you will need to use any credentials from the dataset.
    
    !!!warning "Provisioning time"
        
        Restoring from the dataset will increase the time it takes to create the environment.


=== "Confluence"

    ### Conluence Helm chart version

    `confluence_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Confluence instance.

    ```terraform
    confluence_helm_chart_version = "1.1.0"
    ```

    ### Confluence License

    `confluence_license` takes the license key of Confluence product. Make sure that there is no new lines or spaces in license key.

    ```terraform
    confluence_license = "<LICENSE KEY>"
    ```

    !!!warning "Sensitive data"

        `confluence_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

        Please refer to [Sensitive Data](#sensitive-data) section.
    
    ### Confluence instance resource configuration
    
    The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Jira instance. (Used default values as example.)
    
    ```terraform
    confluence_cpu                 = "2"
    confluence_mem                 = "1Gi"
    confluence_min_heap            = "256m"
    confluence_max_heap            = "512m"
    ```

    ### Database engine version

    `confluence_db_major_engine_version` sets the PostgeSQL engine version that will be used.

    ```terraform
    confluence_db_major_engine_version = "11" 
    ```

    !!! info "Supported DB versions"

        Be sure to use a [DB engine version that is supported by Confluence](https://confluence.atlassian.com/doc/supported-platforms-207488198.html#SupportedPlatforms-Databases){.external} 

    ### Database Instance Class

    `confluence_db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.
    
    ```terraform
    confluence_db_instance_class = "<INSTANCE CLASS>"  # e.g. "db.t3.micro"
    ```
    
    ### Database Allocated Storage
    
    `confluence_db_allocated_storage` sets the allocated storage for the database instance in GiB.
    
    ```terraform
    confluence_db_allocated_storage = 100 
    ```
    
    !!! info "The allowed value range of allocated storage may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.
    
    ### Database IOPS
    
    `confluence_db_iops` sets the requested number of I/O operations per second that the DB instance can support.
    
    ```terraform
    confluence_db_iops = 1000
    ```
    
    !!! info "The allowed value range of IOPS may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

=== "Jira"

    ### Jira Helm chart version

    `jira_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Jira instance.

    ```terraform
    jira_helm_chart_version = "1.1.0"
    ```
    
    ### Jira instance resource configuration
    
    The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Jira instance. (Used default values as example.)
    
    ```terraform
    jira_cpu                 = "2"
    jira_mem                 = "2Gi"
    jira_min_heap            = "384m"
    jira_max_heap            = "786m"
    jira_reserved_code_cache = "512m"
    ```

    ### Database engine version

    `jira_db_major_engine_version` sets the PostgeSQL engine version that will be used.

    ```terraform
    jira_db_major_engine_version = "12" 
    ```

    !!! info "Supported DB versions"

        Be sure to use a [DB engine version that is supported by Jira](https://confluence.atlassian.com/adminjiraserver/supported-platforms-938846830.html#Supportedplatforms-Databases){.external} 

    ### Database Instance Class

    `jira_db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.
    
    ```terraform
    jira_db_instance_class = "<INSTANCE CLASS>"  # e.g. "db.t3.micro"
    ```
    
    ### Database Allocated Storage
    
    `jira_db_allocated_storage` sets the allocated storage for the database instance in GiB.
    
    ```terraform
    jira_db_allocated_storage = 100 
    ```
    
    !!! info "The allowed value range of allocated storage may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.
    
    ### Database IOPS
    
    `jira_db_iops` sets the requested number of I/O operations per second that the DB instance can support.
    
    ```terraform
    jira_db_iops = 1000
    ```
    
    !!! info "The allowed value range of IOPS may vary based on instance class"
    You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

    
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
