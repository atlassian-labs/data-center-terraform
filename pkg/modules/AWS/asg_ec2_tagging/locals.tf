locals {
  ec2_formatted_tags = flatten([for id in data.aws_instances.ec2.ids : [for key, value in data.aws_default_tags.current.tags : {
    tag_key : key
    tag_value : value
    resource_id : id
    iteration_id : "${id}-${key}"
    }
  ]])

  cluster_name = var.state_type == "s3" ? data.terraform_remote_state.s3[0].outputs.eks.cluster_name : data.terraform_remote_state.local[0].outputs.eks.cluster_name
}
