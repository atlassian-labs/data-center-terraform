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
instance_types = ["m5.2xlarge"]

# Desired number of nodes that the node group should launch with initially.
desired_capacity = 1

################################################################################
# Jira Settings
################################################################################

# Helm chart version of Jira
jira_helm_chart_version = "1.2.0"
# By default, Jira Software will use the version defined in the helm chart. If you wish to override the version, uncomment
# the following line and set the jira_software_version to any of the versions available on https://hub.docker.com/r/atlassian/jira-software/tags
#jira_software_version   = "<JIRA_VERSION_TAG>"

# Jira instance resource configuration
jira_cpu                 = "2"
jira_mem                 = "2Gi"
jira_min_heap            = "384m"
jira_max_heap            = "786m"
jira_reserved_code_cache = "512m"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
jira_db_major_engine_version = "12"
jira_db_instance_class       = "db.t3.micro"
jira_db_allocated_storage    = 100
jira_db_iops                 = 1000

################################################################################
# Confluence Settings
################################################################################

# Helm chart version of Confluence
confluence_helm_chart_version = "1.2.0"
# By default, Confluence will use the version defined in the helm chart. If you wish to override the version, uncomment
# the following line and set the confluence_software_version to any of the versions available on https://hub.docker.com/r/atlassian/confluence/tags
#confluence_software_version   = "<CONFLUENCE_VERSION_TAG>"

# Confluence license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_confluence_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#confluence_license = "<LICENSE KEY>"

# Confluence instance resource configuration
confluence_cpu      = "1"
confluence_mem      = "1Gi"
confluence_min_heap = "256m"
confluence_max_heap = "512m"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
confluence_db_major_engine_version = "11"
confluence_db_instance_class       = "db.t3.micro"
confluence_db_allocated_storage    = 100
confluence_db_iops                 = 1000

# Enables Collaborative editing in Confluence
#confluence_collaborative_editing_enabled = true

################################################################################
# Bitbucket Settings
################################################################################

# Helm chart version of Bitbucket
bitbucket_helm_chart_version = "1.2.0"

# Bitbucket license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bitbucket_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#bitbucket_license = "<LICENSE KEY>"

# Bitbucket system admin credentials
# To pre-seed Bitbucket with the system admin information, uncomment the following settings and supply the system admin information:
#
# To avoid storing password in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_`
# (i.e. `TF_VAR_bitbucket_admin_password`) and keep `bitbucket_admin_password` commented out
# If storing password as plain-text is not a concern for this environment, feel free to uncomment `bitbucket_admin_password` and supply system admin password here
#
#bitbucket_admin_username      = "<USERNAME>"
#bitbucket_admin_password      = "<PASSWORD>"
#bitbucket_admin_display_name  = "<DISPLAY NAME>"
#bitbucket_admin_email_address = "<EMAIL ADDRESS>"

# Bitbucket instance resource configuration
bitbucket_cpu      = "1"
bitbucket_mem      = "1Gi"
bitbucket_min_heap = "256m"
bitbucket_max_heap = "512m"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
bitbucket_db_major_engine_version = "13"
bitbucket_db_instance_class       = "db.t3.micro"
bitbucket_db_allocated_storage    = 100
bitbucket_db_iops                 = 1000

# Bitbucket NFS instance resource configuration
#bitbucket_nfs_requests_cpu    = "<REQUESTS CPU>"
#bitbucket_nfs_requests_memory = "<REQUESTS MEMORY>"
#bitbucket_nfs_limits_cpu      = "<LIMITS CPU>"
#bitbucket_nfs_limits_memory   = "<LIMITS MEMORY>"

################################################################################
# Bamboo Settings
################################################################################

# Helm chart version of Bamboo and Bamboo agent instances
bamboo_helm_chart_version       = "1.2.0"
bamboo_agent_helm_chart_version = "1.2.0"

# Bamboo license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
#bamboo_license = "<LICENSE KEY>"

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
#bamboo_admin_display_name  = "<DISPLAY NAME>"
#bamboo_admin_email_address = "<EMAIL ADDRESS>"

# Bamboo instance resource configuration
bamboo_cpu      = "1"
bamboo_mem      = "1Gi"
bamboo_min_heap = "256m"
bamboo_max_heap = "512m"

# Bamboo Agent instance resource configuration
bamboo_agent_cpu = "0.25"
bamboo_agent_mem = "256m"

# Number of Bamboo remote agents to launch
# To install and use the Bamboo agents, you need to provide pre-seed data including a valid Bamboo license and system admin information.
# Feel free to uncomment the following line and supply the number of remote agents.
#number_of_bamboo_agents = 5

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
bamboo_db_major_engine_version = "13"
bamboo_db_instance_class       = "db.t3.micro"
bamboo_db_allocated_storage    = 100
bamboo_db_iops                 = 1000

# (Optional) URL for dataset to import
# The provided default is the dataset used in the DCAPT framework.
# See https://developer.atlassian.com/platform/marketplace/dc-apps-performance-toolkit-user-guide-bamboo
#
#dataset_url = "https://centaurus-datasets.s3.amazonaws.com/bamboo/dcapt-bamboo.zip"
