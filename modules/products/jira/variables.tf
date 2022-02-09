variable "namespace" {
  description = "The namespace where Jira pod will be installed."
  type        = string
}

variable "license" {
  description = "Jira license."
  type        = string
  sensitive   = true
}

variable "jira_configuration" {
  description = "Bamboo resource spec and chart version"
  type        = map(any)
  validation {
    condition = (length(var.jira_configuration) == 5 &&
    alltrue([for o in keys(var.jira_configuration) : contains(["helm_version", "cpu", "mem", "min_heap", "max_heap"], o)]))
    error_message = "Bamboo configuration is not valid1."
  }
}
