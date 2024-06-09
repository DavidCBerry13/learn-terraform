





resource "azurerm_resource_group" "terraform_resource_group" {
  name     = var.project_name
  location = var.azure_region
}


resource "azurerm_service_plan" "terraform_app_service_plan" {
  name                = "pln-${var.project_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}


resource "azurerm_linux_web_app" "terraform_linux_web_app" {
  name                = "web-${var.project_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  service_plan_id     = azurerm_service_plan.terraform_app_service_plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = false
  }
}