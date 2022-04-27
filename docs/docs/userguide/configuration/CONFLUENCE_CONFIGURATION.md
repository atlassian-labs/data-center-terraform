# Confluence configuration

## Application configuration

### Helm chart version

`confluence_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Confluence instance.

```terraform
confluence_helm_chart_version = "1.2.0"
```

### Confluence version tag

Confluence will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/7e7897dda093b174ce66b4294b0783663a4eddaf/src/main/charts/confluence/Chart.yaml#L6). If you want to install a specific version of Bamboo, you can set the `confluence_version_tag` to the version you want to install.

For more information, see [Confluence Version Tags](https://hub.docker.com/r/atlassian/confluence/tags){.external}.

```terraform
confluence_version_tag = "<CONFLUENCE_VERSION_TAG>"
```

### Number of Confluence application nodes

The initial Confluence installation needs to be started with a single application node. After all the setup steps
are finished, it is possible to update the `confluence_replica_count` with a number higher than `1` and run `install.sh` to update
the application node count.

```terraform
# Number of Confluence application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Confluence is fully
# installed and configured.
confluence_replica_count = 1
```

!!! tip "Cluster size"

    [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) installed in the 
    cluster will monitor the amount of required resources and adjust the cluster size to accomodate the requested cpu and memory.

### License

`confluence_license` takes the license key of Confluence product. Make sure that there is no new lines or spaces in license key.

```terraform
confluence_license = "<LICENSE_KEY>"
```

!!! warning "Sensitive data"

    `confluence_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](../CONFIGURATION.md#sensitive-data) section.

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Confluence instance. (Used default values as example.)

```terraform
confluence_cpu                 = "2"
confluence_mem                 = "1Gi"
confluence_min_heap            = "256m"
confluence_max_heap            = "512m"
```

### Collaborative editing

`confluence_collaborative_editing_enabled` enables [Collaborative editing](https://confluence.atlassian.com/doc/collaborative-editing-858771779.html). (default: `true`)

```terraform
confluence_collaborative_editing_enabled = true
```

## RDS Configuration

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
confluence_db_instance_class = "<INSTANCE_CLASS>"  # e.g. "db.t3.micro"
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

### Database name

`confluence_db_name` defines the name of database to be used for the Confluence in RDS instance.

If you restore the database, you need to provide the db name from the snapshot. If the snapshot does not have default db, then name set this variable to `null`.

```terraform
confluence_db_name = "confluence"
```

## Shared home configuration
### Shared home size
`confluence_shared_home_size` sets the size of shared home storage in Gi. Default is 10Gi.

```terraform
confluence_shared_home_size = "10Gi"
```

### NFS server resource configuration
NFS is used as shared home storage for Confluence. The deployment will create an NFS server within the cluster.
The following variables set the initial cpu/memory request sizes including their limits for the NFS instance. (Default values used as example.)

```terraform
# Confluence NFS instance resource configuration
confluence_nfs_requests_cpu    = "1"
confluence_nfs_requests_memory = "1Gi"
confluence_nfs_limits_cpu      = "2"
confluence_nfs_limits_memory   = "2Gi"
```

## Dataset restore configuration
To restore the dataset into the newly created instance, configure all the parameters in this section.

### Database Snapshot Identifier

`confluence_db_snapshot_id` sets the identifier of the DB snapshot to restore from. If you do not specify a value, no AWS RDS snapshot will be used.

```terraform
confluence_db_snapshot_id = "<SNAPSHOT_IDENTIFIER>"   # e.g. "my-snapshot"
```

!!! info "The AWS RDS snapshot must be in the same region and account as the RDS instance to be created."

    You also need to provide the master user credentials (`confluence_db_master_username` and `confluence_db_master_password`) that match the snapshot.

!!! tip "Optimise the restore performance."

    To obtain the best performance, configure Jira RDS that match the snapshot including `confluence_db_instance_class` and `confluence_db_allocated_storage`.

### Database Master Username

`confluence_db_master_username` sets the username for the RDS master user. If you do not specify a value, username is "postgres".

```terraform
confluence_db_master_username = "<DB_MASTER_USERNAME>"   # e.g. "postgres"
```

### Database Master Password

`confluence_db_master_password` sets the password for the RDS master user. If you do not specify a value, a random password will be generated.

```terraform
confluence_db_master_password = "<DB_MASTER_PASSWORD>"   # default value is null
```

### Build Number

`confluence_db_snapshot_build_number` configures Confluence instance with the correct build number that stores in the snapshot.
Without a matching build number, Confluence will not be able to start. 
[List of build numbers](https://developer.atlassian.com/server/confluence/confluence-build-information/).

```terraform
confluence_db_snapshot_build_number = "<BUILD_NUMBER>" # e.g. "8703"
```

### Shared home snapshot id
To restore a shared home dataset, you can provide an EBS snapshot id that contains content of the shared home volume.
This volume will then be mounted to the NFS server and used when the product is started.

`confluence_shared_home_snapshot_id` sets the id of shared home EBS snapshot. 
Make sure the snapshot is available in the region you are deploying to and follows all product requirements.

```terraform
confluence_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"
```

??? Warning "Snapshot and your environment must be in same region"  