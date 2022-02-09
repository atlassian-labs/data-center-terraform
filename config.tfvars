# This file configures the Terraform for Atlassian DC on Kubernetes.
# Please configure this file carefully before installing the infrastructure.
# See https://atlassian-labs.github.io/data-center-terraform/userguide/CONFIGURATION/ for more information.

################################################################################
# Common Settings
################################################################################

# 'environment_name' provides your environment a unique name within a single cloud provider account.
# This value can not be altered after the configuration has been applied.
environment_name = "jjeong-jira"

# Cloud provider region that this configuration will deploy to.
region = "sa-east-1"


# (optional) List of the products to be installed.
# Supported products are jira, confluence, bitbucket, and bamboo.
# e.g.: products = ["jira", "confluence"]
products = ["jira"]

# (Optional) Domain name used by the ingress controller.
# The final ingress domain is a subdomain within this domain. (eg.: environment.domain.com)
# You can also provide a subdomain <subdomain.domain.com> and the final ingress domain will be <environment.subdomain.domain.com>.
# When commented out, the ingress controller is not provisioned and the application is accessible over HTTP protocol (not HTTPS).
#
domain = "deplops.com"

# (Optional) URL for dataset to import
# The provided default is the dataset used in the DCAPT framework.
# See https://developer.atlassian.com/platform/marketplace/dc-apps-performance-toolkit-user-guide-bamboo
#
#dataset_url = "https://centaurus-datasets.s3.amazonaws.com/bamboo/dcapt-bamboo.zip"


# (optional) Custom tags for all resources to be created. Please add all tags you need to propagate among the resources.
resource_tags = {
  Terraform      = "true"
  Name           = "jjeong-test"
  business_unit  = "Engineering-Enterprise DC"
  resource_owner = "jjeong"
  service_name   = "dc-infrastructure"
  git_repository = "github.com/atlassian-labs/data-center-terraform"
}

# Instance types that is preferred for EKS node group.
instance_types = ["m5.xlarge"]
# Desired number of nodes that the node group should launch with initially.
desired_capacity = 2


################################################################################
# Bamboo Settings
################################################################################

# Bamboo license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#
bamboo_license = "AAAB2g0ODAoPeNptUkuPmzAQvvtXWOotkpPAJt02EocNuNtUWUCEVOrrYJxJ4hZsZJvs0l9fh4B2m90DB2b8zfeYeZc3gCPg2Jvh6Xzh3SzmHr5/yLE/9T1UsKpQarwWHKQBuhNWKBnQOKdZmq02FMVNVYBO9lsD2gTz+YAY6svud604K+8OIK0JiIdCJS3jNmYVBO3fI5OHARYxy0L3DHRgdQMobTQ/MgOuDsFZEfF84s1QLyhva+imRPQrXScpzYYOfaqFbjtY6vnTzwMnfWCivCJ1ZXGCC+EG9An0KgqW9JaSWfTdJ++TL7fk/ubjh7e9ZVApC705F8CmKQzXou6S6ma+CUtLJrsw/o/47OiFm9fNK7uj0ShOcvIpyUiaJdE2zFdJTLYb6hpBqMEFsMNFi+0RcD8FU8nVDjSutfoN3OIfR2vrn4vJ5OCysCUzRjA55qqalBcEgQvi1xhHCktl8U4Yq0XRWHCThcFWYd4Yqyp3BWPkMnYrlEzy13twusKM3uU0IstvZ5H9LnpxLvmt/CPVo0QbGgfuI/PpFCX6wKQw7HJ+T6yqS8ChqmomW9TZdI3rI4ngeRE5GIt7O3ivnPmyOQiJd3CCUtVONqInVjYXhj0rDaB/eM4O1DAsAhQb+nU1TX7nOaimKWs4XJS8CuyVPwIUKntyk7aWrI/Yb1IfByau+ABbaXQ=X02mi"

# Bamboo system admin credentials
# WARNING: In case you are restoring an existing dataset (see the `dataset_url` property below), you will need to use credentials
# existing in the dataset to set this section. Otherwise any other value for the `bamboo_admin_*` properties below are ignored.
bamboo_admin_username = "admin"
# To avoid storing system admin password in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_admin_password`) and keep the below line commented out
# If storing password as plain-text is not a concern for this environment, feel free to uncomment the following line and supply system admin password here
bamboo_admin_password      = "admin"
bamboo_admin_display_name  = "Admin"
bamboo_admin_email_address = "admin@foo.com"

# Helm chart version of Bamboo and Bamboo agent instances
bamboo_helm_chart_version       = "1.0.0"
bamboo_agent_helm_chart_version = "1.0.0"

# Bamboo instance resource configuration
bamboo_cpu      = "1"
bamboo_mem      = "1Gi"
bamboo_min_heap = "256m"
bamboo_max_heap = "512m"

# Bamboo Agent instance resource configuration
bamboo_agent_cpu = "0.25"
bamboo_agent_mem = "256m"

# Number of Bamboo remote agents to launch
number_of_bamboo_agents = 5

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
bamboo_db_instance_class    = "db.t3.micro"
bamboo_db_allocated_storage = 100
bamboo_db_iops              = 1000


################################################################################
# Jira Settings
################################################################################


jira_helm_chart_version  = "1.0.0"
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
jira_db_instance_class    = "db.t3.micro"
jira_db_allocated_storage = 100
jira_db_iops              = 1000