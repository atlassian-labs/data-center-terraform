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

# EKS K8S API version. Defaults to 1.25. Allowed values are from 1.21 to 1.25.
# See: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
# eks_version = <EKS_VERSION>

# (optional) List of the products to be installed.
# Supported products are jira, confluence, bitbucket, and bamboo.
# e.g.: products = ["jira", "confluence"]
products = ["<LIST_OF_PRODUCTS>"]

# List of IP ranges that are allowed to access the running applications over the World Wide Web.
# By default the deployed applications are publicly accessible (0.0.0.0/0). You can restrict this access by changing the
# default value to your desired CIDR blocks. e.g. ["10.20.0.0/16" , "99.68.64.0/10"]
whitelist_cidr = ["0.0.0.0/0"]

# By default, Ingress controller listens on 443 and 80. You can enable only http port 80 by
# uncommenting the below line, which will disable port 443. This results in fewer inbound rules in Nginx controller security group.
# This can be used in case you hit the limit which can happen if 30+ whitelist_cidrs are provided.
#enable_https_ingress = false

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

# If you desire to access the cluster with additional roles other than the one used for cluster creation,
# you can define them below.
#eks_additional_roles = [
#  {
#    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
#    username = "ROLE_NAME"
#    groups = [
#      "system:masters"
#    ]
#  }
#]

################################################################################
# Osquery settings. Atlassian only!
################################################################################

# OSquery Fleet Enrollment Host
# osquery_fleet_enrollment_host = "fleet-server.services.atlassian.com"

# The secret needs to be available in Secrets Manager. Terraform DOES NOT
# create the secret. It should be just the secret name, not the full ARN.
# Providing the secret name enables osquery installation in the nodegroup launch template.
# osquery_fleet_enrollment_secret_name = "<FLEET-ENROLLMENT_SECRET-NAME>"

# AWS region to fetch fleet enrollment secret. It can be different from the AWS region the environment is deployed to
# If undefined, current AWS region will be used (the one set in `region` in this file). Defaults to undefined.
# osquery_fleet_enrollment_secret_region_aws = ""

# The value of OSQUERY_ENV that will be used to send logs to Splunk. It should not be something like “production”
# or “prod-west2” but should instead relate to the product, platform, or team. Defaults to osquery_dc_e2e_tests
# osquery_env = "osquery_dc_e2e_tests"

# Osquery version. Defaults to 5.7.0. Osquery is installed as yum package, make sure you test the version before an update
# osquery_version = "5.7.0"

# ATLASSIAN only! Two Atlassian provided roles to push logs to kinesis. Can also be set as env var:
# TF_VAR_kinesis_log_producers_role_arns='{"eu":"$EU_ROLE_ARN","non-eu":"$NON_EU_ROLE_ARN"}'
# kinesis_log_producers_role_arns = {
#   "eu"     = "arn:aws:iam::111111111111:role/pipeline-prod-log-producers-all",
#   "non-eu" = "arn:aws:iam::111111111111:role/pipeline-prod-log-producers-all"
# }

################################################################################
# Jira Settings
################################################################################

# Helm chart version of Jira. By default the latest version is installed.
# jira_helm_chart_version = "<helm_chart_version>"

# Number of Jira application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Jira is fully
# installed and configured.
jira_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#jira_installation_timeout = <MINUTES>

# Termination grace period
# Under certain conditions, pods may be stuck in a Terminating state which forces shared-home pvc to be stuck
# in Terminating too causing Terraform destroy error (timing out waiting for a deleted PVC). Set termination graceful period to 0
# if you encounter such an issue
#jira_termination_grace_period = 0

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
# You must provide Jira license if you wish to restore the database from a snapshot.
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

# Helm chart version of Confluence. By default the latest version is installed.
# confluence_helm_chart_version = "<helm_chart_version>"

# Number of Confluence application nodes
# Note: For initial installation this value needs to be set to 1 and it can be changed only after Confluence is fully
# installed and configured.
confluence_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#confluence_installation_timeout = <MINUTES>

# Termination grace period
# Under certain conditions, pods may be stuck in a Terminating state which forces shared-home pvc to be stuck
# in Terminating too causing Terraform destroy error (timing out waiting for a deleted PVC). Set termination graceful period to 0
# if you encounter such an issue.
# confluence_termination_grace_period = 0

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

# Synchrony instance resource configuration
synchrony_cpu        = "2"
synchrony_mem        = "2.5Gi"
synchrony_min_heap   = "1024m"
synchrony_max_heap   = "2048m"
synchrony_stack_size = "2048k"


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

# Helm chart version of Bitbucket. By default the latest version is installed.
# bitbucket_helm_chart_version = "<helm_chart_version>"

# Number of Bitbucket application nodes
bitbucket_replica_count = 1

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#bitbucket_installation_timeout = <MINUTES>

# Termination grace period
# Under certain conditions, pods may be stuck in a Terminating state which forces shared-home pvc to be stuck
# in Terminating too causing Terraform destroy error (timing out waiting for a deleted PVC). Set termination graceful period to 0
# if you encounter such an issue
#bitbucket_termination_grace_period = 0

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

# Helm chart version of Bamboo and Bamboo agent instances. By default the latest version is installed.
# bamboo_helm_chart_version       = "<helm_chart_version>"
# bamboo_agent_helm_chart_version = "<helm_chart_version>"

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

# Termination grace period
# Under certain conditions, pods may be stuck in a Terminating state which forces shared-home pvc to be stuck
# in Terminating too causing Terraform destroy error (timing out waiting for a deleted PVC). Set termination graceful period to 0
# if you encounter such an issue. This will apply to both Bamboo server and agent pods.
#bamboo_termination_grace_period = 0

################################################################################
# Crowd Settings
################################################################################

# Helm chart version of Crowd and Crowd agent instances. By default the latest version is installed.
# crowd_helm_chart_version       = "<helm_chart_version>"

# By default, Crowd will use the versions defined in their respective Helm charts:
# https://github.com/atlassian/data-center-helm-charts/blob/main/src/main/charts/crowd/Chart.yaml
# If you wish to override these versions, uncomment the following lines and set the crowd_version_tag to any of the versions published on Docker Hub:
# https://hub.docker.com/r/atlassian/crowd/tags
#crowd_version_tag       = "<CROWD_VERSION_TAG>"

# Installation timeout
# Different variables can influence how long it takes the application from installation to ready state. These
# can be dataset restoration, resource requirements, number of replicas and others.
#crowd_installation_timeout = <MINUTES>

# Crowd instance resource configuration
crowd_cpu      = "1"
crowd_mem      = "1Gi"
crowd_min_heap = "256m"
crowd_max_heap = "512m"

# Storage
crowd_local_home_size  = "10Gi"
crowd_shared_home_size = "10Gi"

# Crowd NFS instance resource configuration
#crowd_nfs_requests_cpu    = "<REQUESTS_CPU>"
#crowd_nfs_requests_memory = "<REQUESTS_MEMORY>"
#crowd_nfs_limits_cpu      = "<LIMITS_CPU>"
#crowd_nfs_limits_memory   = "<LIMITS_MEMORY>"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
crowd_db_major_engine_version = "13"
crowd_db_instance_class       = "db.t3.micro"
crowd_db_allocated_storage    = 100
crowd_db_iops                 = 1000
crowd_db_name                 = "crowd"

# Termination grace period
# Under certain conditions, pods may be stuck in a Terminating state which forces shared-home pvc to be stuck
# in Terminating too causing Terraform destroy error (timing out waiting for a deleted PVC). Set termination graceful period to 0
# if you encounter such an issue. This will apply to Crowd pods.
#crowd_termination_grace_period = 0

# Dataset Restore

# Database restore configuration
# If you want to restore the database from a snapshot, uncomment the following line and provide the snapshot identifier.
# This will restore the database from the snapshot and will not create a new database.
# The snapshot should be in the same AWS account and region as the environment to be deployed.
# Please also provide crowd_db_master_username and crowd_db_master_password that matches the ones in snapshot
#crowd_db_snapshot_id           = "<DB_SNAPSHOT_ID>"
#crowd_db_snapshot_build_number = "<BUILD_NUMBER>"

# The master user credential for the database instance.
# If username is not provided, it'll be default to "postgres".
# If password is not provided, a random password will be generated.
#crowd_db_master_username     = "<DB_MASTER_USERNAME>"
#crowd_db_master_password     = "<DB_MASTER_PASSWORD>"

# Shared home restore configuration
# To restore shared home dataset, you can provide EBS snapshot ID that contains content of the shared home volume.
# This volume will be mounted to the NFS server and used when the product is started.
# Make sure the snapshot is available in the region you are deploying to and it follows all product requirements.
#crowd_shared_home_snapshot_id = "<SHARED_HOME_EBS_SNAPSHOT_IDENTIFIER>"
# Crowd license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_crowd_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#crowd_license = "<LICENSE_KEY>"