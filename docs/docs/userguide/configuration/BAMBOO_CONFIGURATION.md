# Bamboo configuration

## Application configuration

### Helm chart version

`bamboo_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bamboo instance.

```terraform
bamboo_helm_chart_version = "1.2.0"
```

### Bamboo version tag

Bamboo will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/7e7897dda093b174ce66b4294b0783663a4eddaf/src/main/charts/bamboo/Chart.yaml#L6). If you want to install a specific version of Bamboo, you can set the `bamboo_version_tag` to the version you want to install.

For more information, see [Bamboo Version Tags](https://hub.docker.com/r/atlassian/bamboo/tags){.external}.

```terraform
bamboo_version_tag = "<BAMBOO_VERSION_TAG>"
```

### Installation timeout

`bamboo_installation_timeout` defines the timeout (in minutes) for product **helm chart installation**. Different variables
can influence how long it takes the application from installation to ready state. These can be dataset restoration,
resource requirements, number of replicas and others.

```terraform
bamboo_installation_timeout = 10
```

### License

`bamboo_license` takes the license key of Bamboo product. Make sure that there is no new lines or spaces in license key.

```terraform
bamboo_license = "<LICENSE_KEY>"
```

!!!warning "Sensitive data"

    `bamboo_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](#sensitive-data) section.

### System Admin Credentials

Four values are required to configure Bamboo system admin credentials.

```terraform
bamboo_admin_username = "<USERNAME>"
bamboo_admin_password = "<PASSWORD>"
bamboo_admin_display_name = "<DISPLAY_NAME>"
bamboo_admin_email_address = "<EMAIL_ADDRESS>"
```

!!!warning "Sensitive data"

    `bamboo_admin_password` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended.

    Please refer to [Sensitive Data](#sensitive-data) section.

!!!info "Restoring from existing dataset"

    If the [`dataset_url` variable](#restoring-from-backup) is provided (see [Restoring from Backup](#restoring-from-backup) below), the _Bamboo System Admin Credentials_ properties are ignored.

    You will need to use user credentials from the dataset to log into the instance.

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Bamboo instance. (Used default values as example.)

```terraform
bamboo_cpu = "1"
bamboo_mem = "1Gi"
bamboo_min_heap = "256m"
bamboo_max_heap = "512m"
```

##  Bamboo Agents configuration

### Agent Helm chart version

`bamboo_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bamboo Agent instance.

```terraform
bamboo_agent_helm_chart_version = "1.2.0"
```

### Agent version tag

Bamboo Agent will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/7e7897dda093b174ce66b4294b0783663a4eddaf/src/main/charts/bamboo-agent/Chart.yaml#L6). If you want to install a specific version of the Agent, you can set the `bamboo_agent_version_tag` to the desired version.

For more information, see [Bamboo Agent Version Tags](https://hub.docker.com/r/atlassian/bamboo-agent-base/tags){.external}.

```terraform
bamboo_agent_version_tag = "<BAMBOO_AGENT_VERSION_TAG>"
```

### Agent instance resource configuration

The following variables set number of CPU and amount of memory of Bamboo Agent instances. (Used default values as example.)

```terraform
bamboo_agent_cpu = "0.25"
bamboo_agent_mem = "256m"
```

### Number of agents

`number_of_bamboo_agents` sets the number of remote agents to be launched. To disable agents, set this value to `0`.

```terraform
number_of_bamboo_agents = 5
```

!!! info "The number of agents is limited to the number of allowed agents in your license."
    
    Any agents beyond the allowed number won't be able to join the cluster.

!!! warning "A valid license is required to install bamboo agents"
    
    Bamboo needs a valid license to install remote agents. Disable agents if you don't provide a license at installation time.

## RDS Configuration

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
bamboo_db_instance_class = "<INSTANCE_CLASS>"  # e.g. "db.t3.micro"
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


### Database name

`bamboo_db_name` defines the name of database to be used for the Bamboo in RDS instance.

```terraform
bamboo_db_name = "bamboo"
```

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