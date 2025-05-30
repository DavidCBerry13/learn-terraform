terraform {
  required_version = ">= 1.8.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }
}