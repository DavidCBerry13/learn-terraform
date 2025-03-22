variable "project_name" {
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
  default     = "terraform-vm"
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}

variable "ssh_key_path" {
  description = "Path to the SSH public key to use for the vmadmin user"
  type        = string
}