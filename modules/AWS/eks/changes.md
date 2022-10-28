subnets => subnet_ids
manage_cluster_iam_resources => create_iam_role

removed:

```

# workers_additional_policies = local.workers_additional_policies

# Managed Node Groups
node_groups_defaults = {
  ami_type        = local.ami_type
  disk_size       = var.instance_disk_size
}

node_groups = {
  appNodes = {
    name                    = "appNode-${replace(join("-", var.instance_types), ".", "_")}"
    max_capacity            = var.max_cluster_capacity
    desired_capacity        = var.min_cluster_capacity
    min_capacity            = var.min_cluster_capacity
    launch_template_id      = module.nodegroup_launch_template.id
    launch_template_version = module.nodegroup_launch_template.version
    subnets                 = slice(var.subnets, 0, 1)
    instance_types          = var.instance_types
    capacity_type           = "ON_DEMAND"
  }
}

map_roles = var.additional_roles
```
