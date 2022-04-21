# Jira configuration

## Application configuration

### Helm chart version

`jira_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Jira instance.

```terraform
jira_helm_chart_version = "1.2.0"
```

### Jira version tag

Jira Software will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/7e7897dda093b174ce66b4294b0783663a4eddaf/src/main/charts/jira/Chart.yaml#L6). If you want to install a specific version of Jira software, you can set the `jira_version_tag` to the version you want to install.

For more information, see [Jira Version Tags](https://hub.docker.com/r/atlassian/jira-software/tags){.external}.

```terraform
jira_version_tag = "<JIRA_VERSION_TAG>"
```

### Number of Jira application nodes

The initial Jira installation needs to be started with a single application node. After all the setup steps
are finished, it is possible to update the `jira_replica_count` with a number higher than `1` and run `install.sh` to update
the application node count.

```terraform
# Number of Jira application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Jira is fully
# installed and configured.
jira_replica_count = 1
```

!!! tip "Cluster size"

    [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) installed in the 
    cluster will monitor the amount of required resources and adjust the cluster size to accomodate the requested cpu and memory.

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Jira instance. (Used default values as example.)

```terraform
jira_cpu                 = "1"
jira_mem                 = "2Gi"
jira_min_heap            = "384m"
jira_max_heap            = "786m"
jira_reserved_code_cache = "512m"
```

## RDS configuration

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
jira_db_instance_class = "<INSTANCE_CLASS>"  # e.g. "db.t3.micro"
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

## Dataset restore configuration
To restore the dataset into the newly created instance, uncomment the following lines and provide all necessary parameters. 

### Database Snapshot Identifier and Jira license

`jira_db_snapshot_identifier` sets the identifier for the DB snapshot to restore from. If you do not specify a value, no AWS RDS snapshot is used.

```terraform
jira_db_snapshot_identifier = "<SNAPSHOT_IDENTIFIER>"   # e.g. "my-snapshot"
```

`jira_license` takes the license key of Jira product. you must provide Jira license key when a RDS snapshot is used. 

```terraform
jira_license = "<LICENSE_KEY>"
```

!!! info "The AWS RDS snapshot must be in the same region and account as the RDS instance."
    
    You also need to provide the master user credentials (`jira_db_master_username` and `jira_db_master_password`) that match the snapshot.

!!! tip "Optimise the restore performance."
    
    To obtain the best performance, configure Jira RDS that match the snapshot including `jira_db_instance_class` and `jira_db_allocated_storage`.

!!! warning "Jira license limitation"

    you can provide `jira_license` ONLY when a RDS snapshot is used. If you plans to provision a new RDS instance comment out `jira_license` and add the license key manually via application UI.

    Please refer to [Sensitive Data](#sensitive-data) section.

### Database Master Username

`jira_db_master_username` sets the username for the RDS master user. If you do not specify a value, username is "postgres".

```terraform
jira_db_master_username = "<DB_MASTER_USERNAME>"   # e.g. "postgres"
```

### Database Master Password

`jira_db_master_password` sets the password for the RDS master user. If you do not specify a value, a random password will be generated.

```terraform
jira_db_master_password = "<DB_MASTER_PASSWORD>"   # default value is null
```

### NFS resource configuration

The following variables set the initial cpu/memory request sizes including their limits for the NFS instance. (Default values used as example.)

```terraform
# Jira NFS instance resource configuration
jira_nfs_requests_cpu    = "<REQUESTS_CPU>"
jira_nfs_requests_memory = "<REQUESTS_MEMORY>"
jira_nfs_limits_cpu      = "<LIMITS_CPU>"
jira_nfs_limits_memory   = "<LIMITS_MEMORY>"
```

### Shared Home Restore

`jira_shared_home_snapshot_id` sets id of Shared home EBS snapshot. This will spin up EBS volume adn it will be mounted to the NFS server and used when the product is started.
```terraform
jira_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"
```

??? Warning "Snapshot and your environment must be in same region"  