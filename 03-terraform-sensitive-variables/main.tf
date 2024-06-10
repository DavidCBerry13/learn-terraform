resource "azurerm_resource_group" "more_complex_app" {
  name     = var.project_name
  location = var.azure_region
}

# -----------------------------------------------------------------------------
# Database Resources
# -----------------------------------------------------------------------------

resource "azurerm_mssql_server" "more_complex_app" {
  name                         = "sql-${var.project_name}"
  location                     = var.azure_region
  resource_group_name          = azurerm_resource_group.more_complex_app.name
  version                      = "12.0"
  administrator_login          = var.db_username
  administrator_login_password = var.db_password

}

resource "azurerm_mssql_database" "more_complex_app" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.more_complex_app.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  sku_name       = "Basic"

  # prevent the possibility of accidental data loss by setting to true
  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Web Resources
# -----------------------------------------------------------------------------

resource "azurerm_service_plan" "more_complex_app" {
  name                = "pln-${var.project_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.more_complex_app.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "more_complex_app" {
  name                = "web-${var.project_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.more_complex_app.name
  service_plan_id     = azurerm_service_plan.more_complex_app.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false
  }

  connection_string {
    name = "DatabaseConnectionString"
    type = "SQLAzure"
    value = "Server=tcp:sql-${var.project_name}.database.windows.net,1433;Initial Catalog=${var.db_name};Persist Security Info=False;User ID=${var.db_username};Password=${var.db_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

