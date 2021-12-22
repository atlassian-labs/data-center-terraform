# This file configures the Terraform for Atlassian DC on Kubernetes.
# Please configure this file carefully before installing the infrastructure.
# See https://github.com/atlassian-labs/data-center-terraform/blob/main/README.md for more information.

# Please define the values to configure the infrastructure before install

# 'environment_name' provides your environment a unique name within a single cloud provider account.
# This value can not be altered after the configuration has been applied.
environment_name = "<ENVIRONMENT>"

# Cloud provider region that this configuration will deploy to.
region = "<REGION>"

# Custom tags for all resources to be created. Please add all tags you need to propagate among the resources.
resource_tags = {
  Terraform = "true"
}

# Instance types that is preferred for node group.
instance_types = ["m5.4xlarge"]

# Desired number of nodes that the node group should launch with initially.
desired_capacity = 2

# (Optional) Domain name used by the ingress controller.
# The final ingress domain is a subdomain within this domain. (eg.: environment.domain.com)
# You can also provide a subdomain <subdomain.domain.com> and the final ingress domain will be <environment.subdomain.domain.com>.
# When commented out, the ingress controller is not provisioned and the application is accessible over HTTP protocol (not HTTPS).
# domain = "<example.com>"

# RDS instance configurable attributes. Note that the allowed value of allocated storage and iops may vary based on instance type.
# You may want to adjust these values according to your needs.
# Documentation can be found via:
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS
db_instance_class    = "db.t3.micro"
db_allocated_storage = 1000
db_iops              = 1000

# Bamboo license
# To avoid storing license in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_license`) and keep the below line commented out
# If storing license as plain-text is not a concern for this environment, feel free to uncomment the following line and supply the license here
#bamboo_license = "<license key>"

# Bamboo system admin credentials
bamboo_admin_username      = "<USERNAME>"
# To avoid storing system admin password in a plain text file, we recommend storing it in an environment variable prefixed with `TF_VAR_` (i.e. `TF_VAR_bamboo_admin_password`) and keep the below line commented out
# If storing password as plain-text is not a concern for this environment, feel free to uncomment the following line and supply system admin password here
#bamboo_admin_password      = "<password>"
bamboo_admin_display_name  = "<DISPLAY NAME>"
bamboo_admin_email_address = "<EMAIL ADDRESS>"
