variable "resource_group_name" {
  description = "The name of the resource group to place the database repources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
}

variable "azure_region" {
  description = "Azure region"
  type        = string
}