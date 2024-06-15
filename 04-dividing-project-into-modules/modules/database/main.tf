

resource "azurerm_mssql_server" "database_server" {
  name                         = "sql-${var.project_name}"
  location                     = var.azure_region
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = var.db_username
  administrator_login_password = var.db_password

}

resource "azurerm_mssql_database" "database" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.database_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 1
  sku_name       = "Basic"
}