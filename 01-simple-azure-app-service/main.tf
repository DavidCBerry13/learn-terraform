terraform {
    required_version = ">= 1.8.5"
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.107"
        }
    }
}


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "terraform_resource_group" {
  name     = "learn-terraform"
  location = "westus2"
}


resource "azurerm_service_plan" "terraform_app_service_plan" {
  name                = "pln-learn-terraform"
  location            = azurerm_resource_group.terraform_resource_group.location
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}


resource "azurerm_linux_web_app" "terraform_linux_web_app" {
  name                = "web-learn-terrafrom"
  location            = azurerm_resource_group.terraform_resource_group.location
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  service_plan_id     = azurerm_service_plan.terraform_app_service_plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = false
  }
}
