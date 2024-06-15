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

variable "database_connection_string" {
  description = "Connection string for app database"
  type        = string  
}

variable "storage_container_sas" {
  description = "Shared Access Signature (SAS) to allow the app to access the storage container"
  type = string
}