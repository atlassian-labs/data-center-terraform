variable "environment_name" {
  description = "Name of the environment."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]{1,24}$", var.environment_name))
    error_message = "Invalid environment name. Valid name is up to 25 characters starting with alphabet and followed by alphanumerics. '-' is allowed as well."
  }
}

variable "vpc_id" {
  description = "VPC ID that hosts the elasticsearch."
  type        = string
}

variable "instance_type" {
  description = "Type of the elasticsearch instances."
  type        = string
  default     = "r4.large.elasticsearch"
  validation {
    condition     = can(regex("^(m[3-5]|r[3-5]|c[4-5]|i[2-3]|d2|t2|ultrawarm1).(1[0|2|4|6|8]x|2x|4x|8x|9x|x)?large.elasticsearch$", var.instance_type))
    error_message = "Elasticsearch instance type is invalid. see 'https://aws.amazon.com/ec2/instance-types'."
  }
}

variable "instance_count" {
  description = "Number of the elasticsearch instances."
  type        = number
}

variable "volume_type" {
  description = "Storage type for the elasticsearch."
  type        = string
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "Volume size for elasticsearch storage."
  type        = number
}
