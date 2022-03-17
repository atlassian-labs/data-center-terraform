# Confluence configuration

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
are finished, it is possible to update the `confluence_replica_count` and run `install.sh` to update
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

!!!warning "Sensitive data"

    `confluence_license` is marked as sensitive, storing in a plain-text `config.tfvars` file is not recommended. 

    Please refer to [Sensitive Data](#sensitive-data) section.

### Instance resource configuration

The following variables set number of CPU, amount of memory, maximum heap size and minimum heap size of Confluence instance. (Used default values as example.)

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

### Collaborative editing

`confluence_collaborative_editing_enabled` enables [Collaborative editing](https://confluence.atlassian.com/doc/collaborative-editing-858771779.html). (default: `true`)

```terraform
confluence_collaborative_editing_enabled = true
```