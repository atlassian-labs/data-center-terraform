# Bitbucket configuration

## Application configuration

### Helm chart version

`bitbucket_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bitbucket instance.

```terraform
Bitbucket_helm_chart_version = "1.2.0"
```

### Bitbucket version tag

Bitbucket will be installed with the default version defined in its [Helm chart](https://github.com/atlassian/data-center-helm-charts/blob/7e7897dda093b174ce66b4294b0783663a4eddaf/src/main/charts/bamboo/Chart.yaml#L6). If you want to install a specific version of Bitbucket, you can set the `bitbucket_version_tag` to the version you want to install.

For more information, see [Bitbucket Version Tags](https://hub.docker.com/r/atlassian/bitbucket/tags){.external}.

```terraform
bitbucket_version_tag = "<BITBUCKET_VERSION_TAG>"
```

### Number of Bitbucket application nodes

`bitbucket_replica_count` defines the desired number of application nodes. If you desire to install more than one 
application node, you must include **System Admin Credentials** and **License properties** listed below in the first installation.
This ensures Bitbucket is using fully automated setup.

```terraform
bitbucket_replica_count = 1
```

!!! tip "Cluster size"

    [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) installed in the 
    cluster will monitor the amount of required resources and adjust the cluster size to accommodate the requested cpu and memory.

### Installation timeout

`bitbucket_installation_timeout` defines the timeout (in minutes) for product **helm chart installation**. Different variables 
can influence how long it takes the application from installation to ready state. These can be dataset restoration, 
resource requirements, number of replicas and others.

```terraform
bitbucket_installation_timeout = 10
```

### License

`bitbucket_license` takes the license key of Bitbucket product. Make sure that there is no new lines or spaces in license key.

```terraform
bitbucket_license = "<LICENSE_KEY>"
```

!!!warning "Sensitive data"

    `bitbucket_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](#sensitive-data) section.

### System Admin Credentials 

Four values are optional to configure Bitbucket system admin credentials. If those values are not provided, then Bitbucket will start in setup page to complete the system admin configuration.

```terraform
bitbucket_admin_username = "<USERNAME>"
bitbucket_admin_password = "<PASSWORD>"
bitbucket_admin_display_name = "<DISPLAY_NAME>"
bitbucket_admin_email_address = "<EMAIL_ADDRESS>"
```

!!!warning "Sensitive data"

    `bitbucket_admin_password` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended.

    Please refer to [Sensitive Data](#sensitive-data) section.

### Display Name
Set the display name of the Bitbucket instance. Note that this value is only used during installation and changing the value during an upgrade has no effect.

```terraform
bitbucket_display_name = "<DISPLAY_NAME>"
```

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Bitbucket instance. (Used default values as example.)

```terraform
bitbucket_cpu      = "1"
bitbucket_mem      = "1Gi"
bitbucket_min_heap = "256m"
bitbucket_max_heap = "512m"
```

## RDS Configuration

### Database engine version

`bitbucket_db_major_engine_version` sets the PostgeSQL engine version that will be used.

```terraform
bitbucket_db_major_engine_version = "13" 
```

!!! info "Supported DB versions"

    Be sure to use a [DB engine version that is supported by Bitbucket](https://confluence.atlassian.com/bitbucketserver/supported-platforms-776640981.html){.external} 


### Database Instance Class

`bitbucket_db_instance_class` sets the DB instance type that allocates the computational, network, and memory capacity required by the planned workload of the DB instance. For more information about available instance classes, see [DB instance classes — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html){.external}.

```terraform
bitbucket_db_instance_class = "<INSTANCE_CLASS>"  # e.g. "db.t3.micro"
```

### Database Allocated Storage

`bitbucket_db_allocated_storage` sets the allocated storage for the database instance in GiB.

```terraform
bitbucket_db_allocated_storage = 100 
```

!!! info "The allowed value range of allocated storage may vary based on instance class"
You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Database IOPS

`bitbucket_db_iops` sets the requested number of I/O operations per second that the DB instance can support.

```terraform
bitbucket_db_iops = 1000
```

!!! info "The allowed value range of IOPS may vary based on instance class"
You may want to adjust these values according to your needs. For more information, see [Amazon RDS DB instance storage — Amazon Relational Database Service](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html){.external}.

### Database name

`bitbucket_db_name` defines the name of database to be used for the Bitbucket in RDS instance.

If you restore the database, you need to provide the db name from the snapshot. If the snapshot does not have default db name, then set this variable to `null`.

```terraform
bitbucket_db_name = "bitbucket"
```

## NFS and Elasticsearch Configuration


### NFS resource configuration

The following variables set the initial cpu/memory request sizes including their limits for the NFS instance. (Default values used as example.)

```terraform
# Bitbucket NFS instance resource configuration
bitbucket_nfs_requests_cpu    = "1"
bitbucket_nfs_requests_memory = "1Gi"
bitbucket_nfs_limits_cpu      = "2"
bitbucket_nfs_limits_memory   = "2Gi"
```

### Elasticsearch Configuration

The following variables set the request for number of CPU, amount of memory, amount of storage, and the number of instances in elasticsearch cluster. (Used default values as example.)

```terraform
# Elasticsearch resource configuration for Bitbucket
bitbucket_elasticsearch_requests_cpu    = "0.5"
bitbucket_elasticsearch_requests_memory = "0.5Gi"
bitbucket_elasticsearch_limits_cpu      = "1"
bitbucket_elasticsearch_limits_memory   = "1Gi"
bitbucket_elasticsearch_storage         = 10
bitbucket_elasticsearch_replicas        = 2
```


## Dataset restore configuration

To restore the dataset into the newly created instance, uncomment the following lines and provide all necessary parameters.

### Database Snapshot Identifier

`bitbucket_db_snapshot_id` sets the identifier for the DB snapshot to restore from. If you do not specify a value, no AWS RDS snapshot is used.

```terraform
bitbucket_db_snapshot_id = "<SNAPSHOT_IDENTIFIER>"   # e.g. "my-snapshot"
```

!!! info "The AWS RDS snapshot must be in the same region and account as the RDS instance."

    You also need to provide the master user credentials (`bitbucket_db_master_username` and `bitbucket_db_master_password`) that match the snapshot.

!!! tip "Optimise the restore performance."

    To obtain the best performance, configure Bitbucket RDS that match the snapshot including `bitbucket_db_instance_class` and `bitbucket_db_allocated_storage`.

### Database Master Username

'bitbucket_db_master_username' sets the username for the RDS master user. If you do not specify a value, username is "postgres".

```terraform
bitbucket_db_master_username = "<DB_MASTER_USERNAME>"   # e.g. "postgres"
```

### Database Master Password

'bitbucket_db_master_password' sets the password for the RDS master user. If you do not specify a value, a random password will be generated.

```terraform
bitbucket_db_master_password = "<DB_MASTER_PASSWORD>"   # default value is null
```

### Shared home snapshot id
To restore a shared home dataset, you can provide an EBS snapshot ID that contains the content of the shared home volume.
This volume will then be mounted to the NFS server and used when the product is started.

`bitbucket_shared_home_snapshot_id` sets the id of the shared home EBS snapshot to use. This will spin up an EBS volume that will be mounted to the NFS server and used when the product is started.
Make sure the snapshot is available in the region you are deploying to and follows all product requirements.

```terraform
bitbucket_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"
```

??? Warning "Snapshot and your environment must be in same region"  