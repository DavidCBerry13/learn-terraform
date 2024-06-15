

resource "azurerm_service_plan" "app_service_plan" {
  name                = "pln-${var.project_name}"
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "web-${var.project_name}"
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false
  }

  app_settings = {
    StorageContainerSasUrl = var.storage_container_sas
  }

  connection_string {
    name = "DatabaseConnectionString"
    type = "SQLAzure"
    value = var.database_connection_string
  }
}