variable "project_name" {
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
  default     = "learn-terraform"
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}

