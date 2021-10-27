# To customise the infrastructure you must provide the value for each of these parameters in config.tfvar

variable "region" {
  description = "Name of the AWS region."
  type = string
}

variable "environment_name" {
  description = "Name for this environment that is going to be deployed. The value will be used to form the name of some resources."
  type = string
}

variable "custom_tags" {
  description = "Additional tags for all resources to be created."
  type = map(string)
}
