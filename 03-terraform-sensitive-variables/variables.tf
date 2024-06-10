variable "project_name" {  
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
  default     = "terraform-web-app"
}

variable "azure_region" {  
  description = "Azure region"
  type        = string
  default     = "westus2"
}

variable "db_name" {  
  description = "Database name"
  type        = string  
  default     = "terraform-db"
}

variable "db_username" {  
  description = "Database username"
  type        = string  
  default     = "azsqladmin"
  sensitive   = true
}

variable "db_password" {  
  description = "Database password"
  type        = string  
  default     = null
  sensitive   = true
}