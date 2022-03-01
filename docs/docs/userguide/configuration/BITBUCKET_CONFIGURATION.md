# Bitbucket configuration

### Helm chart version

`bitbucket_helm_chart_version` sets the [Helm chart](https://github.com/atlassian/data-center-helm-charts){.external} version of Bitbucket instance.

```terraform
Bitbucket_helm_chart_version = "1.2.0"
```

### Bitbucket version tag

Bitbucket will be installed with the default version defined in Hem chart. If you want to install a specific version of Bitbucket, you can set the `bitbucket_version_tag` to the version you want to install.

For more information, see [Bitbucket Version Tags](https://hub.docker.com/r/atlassian/bitbucket/tags){.external}.

```terraform
bitbucket_version_tag = "<BITBUCKET_VERSION_TAG>"
```


### License

`bitbucket_license` takes the license key of Bitbucket product. Make sure that there is no new lines or spaces in license key.

```terraform
bitbucket_license = "<LICENSE KEY>"
```

!!!warning "Sensitive data"

    `bitbucket_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](#sensitive-data) section.

### System Admin Credentials 

Four values are optional to configure Bitbucket system admin credentials. If those values are not provided, then Bitbucket will start in setup page to complete the system admin configuration.

```terraform
bitbucket_admin_username = "<USERNAME>"
bitbucket_admin_password = "<PASSWORD>"
bitbucket_admin_display_name = "<DISPLAY NAME>"
bitbucket_admin_email_address = "<EMAIL ADDRESS>"
```

!!!warning "Sensitive data"

    `bitbucket_admin_password` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended.

    Please refer to [Sensitive Data](#sensitive-data) section.

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Bitbucket instance. (Used default values as example.)

```terraform
bitbucket_cpu      = "1"
bitbucket_mem      = "1Gi"
bitbucket_min_heap = "256m"
bitbucket_max_heap = "512m"
```

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
bitbucket_db_instance_class = "<INSTANCE CLASS>"  # e.g. "db.t3.micro"
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

### NFS resource configuration

The following variables set the initial cpu/memory request sizes including their limits for the NFS instance. (Default values used as example.)



```terraform
# Bitbucket NFS instance resource configuration
bitbucket_nfs_requests_cpu    = "0.25"
bitbucket_nfs_requests_memory = "256Mi"
bitbucket_nfs_limits_cpu      = "0.25"
bitbucket_nfs_limits_memory   = "256Mi"
```

### Elasticsearch Configuration

The following variables set the request for number of CPU, amount of memory, amount of storage, and the number of instances in elasticsearch cluster. (Used default values as example.)

```terraform
# Elasticsearch resource configuration for Bitbucket
bitbucket_elasticsearch_cpu      = "0.25"
bitbucket_elasticsearch_mem      = "1Gi"
bitbucket_elasticsearch_storage  = 10
bitbucket_elasticsearch_replicas = 2
```