# Jira configuration

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

The initial Jira installation need's to be started with a single application node. After all the setup steps
are finished, it is possible to update the `jira_replica_count` with a number higher than one and run `install.sh` to update
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
