# This file configures the Terraform for Atlassian DC on Kubernetes.
# Please configure this file carefully before installing the infrastructure.
# See https://atlassian-labs.github.io/data-center-terraform/userguide/CONFIGURATION/ for more information.

################################################################################
# Common Settings
################################################################################

# 'environment_name' provides your environment a unique name within a single cloud provider account.
# This value can not be altered after the configuration has been applied.
environment_name = "<ENVIRONMENT>"

# Cloud provider region that this configuration will deploy to.
region = "<REGION>"

# (optional) List of the products to be installed.
# Supported products are jira, confluence, bitbucket, and bamboo.
# e.g.: products = ["jira", "confluence"]
products = ["<LIST_OF_PRODUCTS>"]

# (Optional) Domain name used by the ingress controller.
# The final ingress domain is a subdomain within this domain. (eg.: environment.domain.com)
# You can also provide a subdomain <subdomain.domain.com> and the final ingress domain will be <environment.subdomain.domain.com>.
# When commented out, the ingress controller is not provisioned and the application is accessible over HTTP protocol (not HTTPS).
#
#domain = "<example.com>"

# (optional) Custom tags for all resources to be created. Please add all tags you need to propagate among the resources.
resource_tags = {
  Terraform = "true"
}

# Instance types that is preferred for EKS node group.
instance_types     = ["m5.2xlarge"]
instance_disk_size = 50

# Minimum and maximum size of the EKS cluster.
# Cluster-autoscaler is installed in the EKS cluster that will manage the requested capacity
# and increase/decrease the number of nodes accordingly. This ensures there is always enough resources for the workloads
# and removes the need to change this value.
min_cluster_capacity = 1
max_cluster_capacity = 5

################################################################################
# Jira Settings
################################################################################

# Helm chart version of Jira
jira_helm_chart_version = "1.3.0"

# Number of Jira application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Jira is fully
# installed and configured.
jira_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#jira_installation_timeout = <MINUTES>

# By default, Jira Software will use the version defined in the Helm chart. If you wish to override the version, uncomment
# the following line and set the jira_version_tag to any of the versions available on https://hub.docker.com/r/atlassian/jira-software/tags
#jira_version_tag = "<JIRA_VERSION_TAG>"

# To select a different image repository for the Jira application, you can change following variable:
# Official suitable values are:
# - "atlassian/jira-software"
# - "atlassian/jira-servicemanagement"
#jira_image_repository = "atlassian/jira-software"

# Jira instance resource configuration
jira_cpu                 = "2"
jira_mem                 = "2Gi"
jira_min_heap            = "384m"
jira_max_heap            = "786m"
jira_reserved_code_cache = "512m"

# Jira NFS instance resource configuration
#jira_nfs_requests_cpu    = "<REQUESTS_CPU>"
#jira_nfs_requests_memory = "<REQUESTS_MEMORY>"
#jira_nfs_limits_cpu      = "<LIMITS_CPU>"
#jira_nfs_limits_memory   = "<LIMITS_MEMORY>"

# Shared home restore configuration
# To restore a shared home dataset, you can provide an EBS snapshot ID that contains the content of the shared home volume.
# This volume will be mounted to the NFS server and used when the product is started.
# Make sure the snapshot is available in the region you are deploying to and it follows all product requirements.
#jira_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"

# Storage
# initial volume size of local/shared home EBS.
jira_local_home_size  = "10Gi"
jira_shared_home_size = "10Gi"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
jira_db_major_engine_version = "12"
jira_db_instance_class       = "db.t3.micro"
jira_db_allocated_storage    = 100
jira_db_iops                 = 1000
# If you restore the database, make sure `jira_db_name' is set to the db name from the snapshot.
# Set `null` if the snapshot does not have a default db name.
jira_db_name = "jira"

# Database restore configuration
# If you want to restore the database from a snapshot, uncomment the following line and provide the snapshot identifier.
# This will restore the database from the snapshot and will not create a new database.
# The snapshot should be in the same AWS account and region as the environment to be deployed.
# You must provide Jira license if you wish to retore the database from a snapshot.
# You must provide jira_db_master_username and jira_db_master_password that matches the ones in snapshot
#jira_db_snapshot_id = "<DB_SNAPSHOT_ID>"
#jira_license = "<LICENSE_KEY>"

# The master user credential for the database instance.
# If username is not provided, it'll be default to "postgres".
# If password is not provided, a random password will be generated.
#jira_db_master_username     = "<DB_MASTER_USERNAME>"
#jira_db_master_password     = "<DB_MASTER_PASSWORD>"

################################################################################
# Confluence Settings
################################################################################

# Helm chart version of Confluence
confluence_helm_chart_version = "1.3.0"

# Number of Confluence application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Confluence is fully
# installed and configured.
confluence_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#confluence_installation_timeout = <MINUTES>

# By default, Confluence will use the version defined in the Helm chart. If you wish to override the version, uncomment
# the following line and set the confluence_version_tag to any of the versions available on https://hub.docker.com/r/atlassian/confluence/tags
#confluence_version_tag = "<CONFLUENCE_VERSION_TAG>"

# Confluence license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_confluence_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#confluence_license = "<LICENSE_KEY>"

# Confluence instance resource configuration
confluence_cpu      = "2"
confluence_mem      = "2Gi"
confluence_min_heap = "1024m"
confluence_max_heap = "2048m"

# Storage
confluence_local_home_size  = "10Gi"
confluence_shared_home_size = "10Gi"

# Confluence NFS instance resource configuration
#confluence_nfs_requests_cpu    = "<REQUESTS_CPU>"
#confluence_nfs_requests_memory = "<REQUESTS_MEMORY>"
#confluence_nfs_limits_cpu      = "<LIMITS_CPU>"
#confluence_nfs_limits_memory   = "<LIMITS_MEMORY>"

# Shared home restore configuration
# To restore shared home dataset, you can provide EBS snapshot ID of the shared home volume.
# This volume will be mounted to the NFS server and used when the product is started.
# Make sure the snapshot is available in the region you are deploying to and it follows all product requirements.
#confluence_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
confluence_db_major_engine_version = "11"
confluence_db_instance_class       = "db.t3.micro"
confluence_db_allocated_storage    = 100
confluence_db_iops                 = 1000
# If you restore the database, make sure `confluence_db_name' is set to the db name from the snapshot.
# Set `null` if the snapshot does not have a default db name.
confluence_db_name = "confluence"

# Database restore configuration
# If you want to restore the database from a snapshot, uncomment the following lines and provide the snapshot identifier.
# This will restore the database from the snapshot and will not create a new database.
# The snapshot should be in the same AWS account and region as the environment to be deployed.
# Please also provide confluence_db_master_username and confluence_db_master_password that matches the ones in snapshot
# Build number stored within the snapshot and Confluence license are also required, so that Confluence can be fully setup prior to start.
#confluence_db_snapshot_id = "<DB_SNAPSHOT_ID>"
#confluence_db_snapshot_build_number = "<BUILD_NUMBER>"

# The master user credential for the database instance.
# If username is not provided, it'll be default to "postgres".
# If password is not provided, a random password will be generated.
#confluence_db_master_username = "<DB_MASTER_USERNAME>"
#confluence_db_master_password = "<DB_MASTER_PASSWORD>"

# Enables Collaborative editing in Confluence
confluence_collaborative_editing_enabled = true

################################################################################
# Bitbucket Settings
################################################################################

# Helm chart version of Bitbucket
bitbucket_helm_chart_version = "1.3.0"

# Number of Bitbucket application nodes
bitbucket_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#bitbucket_installation_timeout = <MINUTES>

# By default, Bitbucket will use the version defined in the Bitbucket Helm chart:
# https://github.com/atlassian/data-center-helm-charts/blob/main/src/main/charts/bitbucket/Chart.yaml 
# If you wish to override the version, uncomment the following line and set the bitbucket_version_tag to any of the versions published for Bitbucket on Docker Hub: https://hub.docker.com/r/atlassian/bitbucket/tags
#bitbucket_version_tag = "<BITBUCKET_VERSION_TAG>"

# Bitbucket license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bitbucket_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#bitbucket_license = "<LICENSE_KEY>"

# Bitbucket system admin credentials
# To pre-seed Bitbucket with the system admin information, uncomment the following settings and supply the system admin information:
#
# To avoid storing password in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_`
# (i.e. `TF_VAR_bitbucket_admin_password`) and keep `bitbucket_admin_password` commented out
# If storing password as plain-text is not a concern for this environment, feel free to uncomment `bitbucket_admin_password` and supply system admin password here
#
#bitbucket_admin_username      = "<USERNAME>"
#bitbucket_admin_password      = "<PASSWORD>"
#bitbucket_admin_display_name  = "<DISPLAY_NAME>"
#bitbucket_admin_email_address = "<EMAIL_ADDRESS>"

# The display name of Bitbucket instance
#bitbucket_display_name = "<DISPLAY_NAME>"

# Bitbucket instance resource configuration
bitbucket_cpu      = "1"
bitbucket_mem      = "1Gi"
bitbucket_min_heap = "256m"
bitbucket_max_heap = "512m"

# Storage
bitbucket_local_home_size  = "10Gi"
bitbucket_shared_home_size = "10Gi"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
bitbucket_db_major_engine_version = "13"
bitbucket_db_instance_class       = "db.t3.micro"
bitbucket_db_allocated_storage    = 100
bitbucket_db_iops                 = 1000
# If you restore the database, make sure `bitbucket_db_name' is set to the db name from the snapshot.
# Set `null` if the snapshot does not have a default db name.
bitbucket_db_name = "bitbucket"

# Bitbucket NFS instance resource configuration
#bitbucket_nfs_requests_cpu    = "<REQUESTS_CPU>"
#bitbucket_nfs_requests_memory = "<REQUESTS_MEMORY>"
#bitbucket_nfs_limits_cpu      = "<LIMITS_CPU>"
#bitbucket_nfs_limits_memory   = "<LIMITS_MEMORY>"

# Elasticsearch resource configuration for Bitbucket
#bitbucket_elasticsearch_requests_cpu    = "<REQUESTS_CPU>"
#bitbucket_elasticsearch_requests_memory = "<REQUESTS_MEMORY>"
#bitbucket_elasticsearch_limits_cpu      = "<LIMITS_CPU>"
#bitbucket_elasticsearch_limits_memory   = "<LIMITS_MEMORY>"
#bitbucket_elasticsearch_storage         = "<REQUESTS_STORAGE>"
#bitbucket_elasticsearch_replicas        = "<NUMBER_OF_NODES>"

# Dataset Restore

# Database restore configuration
# If you want to restore the database from a snapshot, uncomment the following line and provide the snapshot identifier.
# This will restore the database from the snapshot and will not create a new database.
# The snapshot should be in the same AWS account and region as the environment to be deployed.
# Please also provide bitbucket_db_master_username and bitbucket_db_master_password that matches the ones in snapshot
#bitbucket_db_snapshot_id = "<DB_SNAPSHOT_ID>"

# The master user credential for the database instance.
# If username is not provided, it'll be default to "postgres".
# If password is not provided, a random password will be generated.
#bitbucket_db_master_username     = "<DB_MASTER_USERNAME>"
#bitbucket_db_master_password     = "<DB_MASTER_PASSWORD>"

# Shared home restore configuration
# To restore shared home dataset, you can provide EBS snapshot ID that contains content of the shared home volume.
# This volume will be mounted to the NFS server and used when the product is started.
# Make sure the snapshot is available in the region you are deploying to and it follows all product requirements.
#bitbucket_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"

################################################################################
# Bamboo Settings
################################################################################

# Helm chart version of Bamboo and Bamboo agent instances
bamboo_helm_chart_version       = "1.3.0"
bamboo_agent_helm_chart_version = "1.3.0"

# By default, Bamboo and the Bamboo Agent will use the versions defined in their respective Helm charts:
# https://github.com/atlassian/data-center-helm-charts/blob/main/src/main/charts/bamboo/Chart.yaml
# https://github.com/atlassian/data-center-helm-charts/blob/main/src/main/charts/bamboo-agent/Chart.yaml
# If you wish to override these versions, uncomment the following lines and set the bamboo_version_tag and bamboo_agent_version_tag to any of the versions published on Docker Hub:
# https://hub.docker.com/r/atlassian/bamboo/tags 
# https://hub.docker.com/r/atlassian/bamboo-agent-base/tags
#bamboo_version_tag       = "<BAMBOO_VERSION_TAG>"
#bamboo_agent_version_tag = "<BAMBOO_AGENT_VERSION_TAG>"

# Bamboo license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#bamboo_license = "<LICENSE_KEY>"

# Bamboo system admin credentials
# To pre-seed Bamboo with the system admin information, uncomment the following settings and supply the system admin information:
#
# WARNING: In case you are restoring an existing dataset (see the `dataset_url` property below), you will need to use credentials
# existing in the dataset to set this section. Otherwise any other value for the `bamboo_admin_*` properties below are ignored.
#
# To avoid storing password in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_`
# (i.e. `TF_VAR_bamboo_admin_password`) and keep `bamboo_admin_password` commented out
# If storing password as plain-text is not a concern for this environment, feel free to uncomment `bamboo_admin_password` and supply system admin password here
#
#bamboo_admin_username      = "<USERNAME>"
#bamboo_admin_password      = "<PASSWORD>"
#bamboo_admin_display_name  = "<DISPLAY_NAME>"
#bamboo_admin_email_address = "<EMAIL_ADDRESS>"

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#bamboo_installation_timeout = <MINUTES>

# Bamboo instance resource configuration
bamboo_cpu      = "1"
bamboo_mem      = "1Gi"
bamboo_min_heap = "256m"
bamboo_max_heap = "512m"

# Bamboo Agent instance resource configuration
bamboo_agent_cpu = "0.25"
bamboo_agent_mem = "256m"

# Storage
bamboo_local_home_size  = "10Gi"
bamboo_shared_home_size = "10Gi"

# Bamboo NFS instance resource configuration
#bamboo_nfs_requests_cpu    = "<REQUESTS_CPU>"
#bamboo_nfs_requests_memory = "<REQUESTS_MEMORY>"
#bamboo_nfs_limits_cpu      = "<LIMITS_CPU>"
#bamboo_nfs_limits_memory   = "<LIMITS_MEMORY>"

# Number of Bamboo remote agents to launch
# To install and use the Bamboo agents, you need to provide pre-seed data including a valid Bamboo license and system admin information.
number_of_bamboo_agents = 5

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
bamboo_db_major_engine_version = "13"
bamboo_db_instance_class       = "db.t3.micro"
bamboo_db_allocated_storage    = 100
bamboo_db_iops                 = 1000
bamboo_db_name                 = "bamboo"

# (Optional) URL for dataset to import
# The provided default is the dataset used in the DCAPT framework.
# See https://developer.atlassian.com/platform/marketplace/dc-apps-performance-toolkit-user-guide-bamboo
#
#dataset_url = "https://centaurus-datasets.s3.amazonaws.com/bamboo/dcapt-bamboo.zip"
