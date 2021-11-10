# This file configures the Terraform for Atlassian DC on Kubernetes.
# Please configure this file carefully before installing the infrastructure.
# See https://github.com/atlassian-labs/data-center-terraform/blob/main/README.md for more information.

# Please define the values to configure the infrastructure before install

# 'environment_name' provides your environment a unique name within a single cloud provider account.
# This value can not be altered after the configuration has been applied.
environment_name = "efs-test"

# Cloud provider region that this configuration will deploy to.
region = "ap-northeast-2"

# Custom tags for all resources to be created. Please add all tags you need to propagate among the resources.
resource_tags = {
  Terraform = "true"
  business_unit=  "Engineering-Enterprise DC",
	service_name=   "dc-infrastructure",
	git_repository= "github.com/atlassian-labs/data-center-terraform",
}

# Instance types that is preferred for node group.
instance_types = ["m5.xlarge"]

# Desired number of nodes that the node group should launch with initially.
desired_capacity = 1

# Domain name base for the ingress controller. The final domain is subdomain within this domain. (eg.: environment.domain.com)
domain = "deplops.com"
