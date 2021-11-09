# This file configures the Terraform for Atlassian DC on Kubernetes.
# Please configure this file carefully before installing the infrastructure.
# See https://github.com/atlassian-labs/data-center-terraform/blob/main/README.md for more information. 

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
instance_types = ["m5.xlarge"]

# Desired number of nodes that the node group should launch with initially.
desired_capacity = 1

