#
# resource "aws_security_group" "worker_nodes_sg" {
#   name_prefix        = var.cluster_name
#   description        = "Allow comms in the cluster"
#   vpc_id             = var.vpc_id
#
#   ingress {
#     description      = "Allow tcp comms from master"
#     from_port        = 53
#     to_port          = 10250
#     protocol         = "tcp"
#     security_groups  = [module.eks.cluster_security_group_id]
#   }
#
#   ingress {
#     description      = "Allow comms between nodes"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     self             = true
#   }
#
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
#
# }
#
#
# resource "aws_iam_role" "eks_cluster" {
#   name_prefix = "eks-${var.cluster_name}"
#
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }
#
# resource "aws_iam_role" "self_managed_nodes_group" {
#   name_prefix = var.cluster_name
#
#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }
#
# resource "aws_iam_instance_profile" "self_managed_worker_nodes" {
#   name_prefix = var.cluster_name
#   role = aws_iam_role.self_managed_nodes_group.name
# }
