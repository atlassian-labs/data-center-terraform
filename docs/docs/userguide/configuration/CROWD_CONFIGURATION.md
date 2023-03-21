# Crowd configuration

## Application configuration

### Helm chart version

`crowd_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Crowd instance.

```terraform
crowd_helm_chart_version = "1.10.0"
```

### Crowd version tag

Crowd will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/main/src/main/charts/crowd/Chart.yaml#L6). If you want to install a specific version of Crowd, you can set the `crowd_version_tag` to the version you want to install.

For more information, see [Crowd Version Tags](https://hub.docker.com/r/atlassian/crowd/tags){.external}.

```terraform
crowd_version_tag = "<Crowd_VERSION_TAG>"
```

### Number of Crowd application nodes

The initial Crowd installation needs to be started with a single application node. After all the setup steps
are finished, it is possible to update the `crowd_replica_count` with a number higher than `1` and run `install.sh` to update
the application node count.

```terraform
# Number of Crowd application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Crowd is fully
# installed and configured.
crowd_replica_count = 1
```

!!! tip "Cluster size"

    [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) installed in the 
    cluster will monitor the amount of required resources and adjust the cluster size to accomodate the requested cpu and memory.

### Installation timeout

`crowd_installation_timeout` defines the timeout (in minutes) for product **helm chart installation**. Different variables
can influence how long it takes the application from installation to ready state. These can be dataset restoration,
resource requirements, number of replicas and others.

```terraform
crowd_installation_timeout = 10
```

### Crowd instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Crowd instance. (Used default values as example.)

```terraform
crowd_cpu                 = "2"
crowd_mem                 = "1Gi"
crowd_min_heap            = "256m"
crowd_max_heap            = "512m"
```

## RDS Configuration

### Database engine version

`crowd_db_major_engine_version` sets the PostgeSQL engine version that will be used.

```terraform
crowd_db_major_engine_version = "13" 
```

!!! info "Supported DB versions"

    Be sure to use a [DB engine version that is supported by crowd](https://confluence.atlassian.com/doc/supported-platforms-207488198.html#SupportedPlatforms-Databases){.external} 

!!! info "Restore from snapshot"

    This value is ignored if RDS snaphost is provided with `crowd_db_snapshot_id`.

### Database Instance Class

`crowd_db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.

```terraform
crowd_db_instance_class = "<INSTANCE_CLASS>"  # e.g. "db.t3.micro"
```

### Database Allocated Storage

`crowd_db_allocated_storage` sets the allocated storage for the database instance in GiB.

```terraform
crowd_db_allocated_storage = 100 
```

!!! info "The allowed value range of allocated storage may vary based on instance class"
You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Database IOPS

`crowd_db_iops` sets the requested number of I/O operations per second that the DB instance can support.

```terraform
crowd_db_iops = 1000
```

!!! info "The allowed value range of IOPS may vary based on instance class"
You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Database name

`crowd_db_name` defines the name of database to be used for the crowd in RDS instance.

If you restore the database, you need to provide the db name from the snapshot. If the snapshot does not have default db, then name set this variable to `null`.

```terraform
crowd_db_name = "crowd"
```

## Shared home configuration
### Shared home size
`crowd_shared_home_size` sets the size of shared home storage in Gi. Default is 10Gi.

```terraform
crowd_shared_home_size = "10Gi"
```

## Local home configuration
### Local home size
`crowd_local_home_size` sets the size of shared home storage in Gi. Default is 10Gi.

```terraform
crowd_local_home_size = "10Gi"
```

### NFS server resource configuration
NFS is used as shared home storage for Crowd. The deployment will create an NFS server within the cluster.
The following variables set the initial cpu/memory request sizes including their limits for the NFS instance. (Default values used as example.)

```terraform
# crowd NFS instance resource configuration
crowd_nfs_requests_cpu    = "1"
crowd_nfs_requests_memory = "1Gi"
crowd_nfs_limits_cpu      = "2"
crowd_nfs_limits_memory   = "2Gi"
```

## Dataset restore configuration
To restore the dataset into the newly created instance, configure all the parameters in this section.

### Database Snapshot Identifier

`crowd_db_snapshot_id` sets the identifier of the DB snapshot to restore from. If you do not specify a value, no AWS RDS snapshot will be used.

```terraform
crowd_db_snapshot_id = "<SNAPSHOT_IDENTIFIER>"   # e.g. "my-snapshot"
```

!!! info "The AWS RDS snapshot must be in the same region and account as the RDS instance to be created."

    You also need to provide the master user credentials (`crowd_db_master_username` and `crowd_db_master_password`) that match the snapshot.

!!! tip "Optimise the restore performance."

    To obtain the best performance, configure Crowd RDS that match the snapshot including `crowd_db_instance_class` and `crowd_db_allocated_storage`.

### Database Master Username

`crowd_db_master_username` sets the username for the RDS master user. If you do not specify a value, username is "postgres".

```terraform
crowd_db_master_username = "<DB_MASTER_USERNAME>"   # e.g. "postgres"
```

### Database Master Password

`crowd_db_master_password` sets the password for the RDS master user. If you do not specify a value, a random password will be generated.

```terraform
crowd_db_master_password = "<DB_MASTER_PASSWORD>"   # default value is null
```

### Build Number

`crowd_db_snapshot_build_number` configures Crowd instance with the correct build number that stores in the snapshot.
Without a matching build number, Crowd will not be able to start.
[List of build numbers](https://confluence.atlassian.com/crowdkb/crowd-build-and-version-numbers-reference-703401603.html).

```terraform
crowd_db_snapshot_build_number = "<BUILD_NUMBER>" # e.g. "8703"
```

### Shared home snapshot id
To restore a shared home dataset, you can provide an EBS snapshot id that contains content of the shared home volume.
This volume will then be mounted to the NFS server and used when the product is started.

`crowd_shared_home_snapshot_id` sets the id of shared home EBS snapshot.
Make sure the snapshot is available in the region you are deploying to and follows all product requirements.

```terraform
crowd_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"
```

??? Warning "Snapshot and your environment must be in same region"  