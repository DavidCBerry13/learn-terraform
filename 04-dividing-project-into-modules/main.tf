resource "azurerm_resource_group" "modularized_app" {
  name     = var.project_name
  location = var.azure_region
}


module "database" {
  source    = "./modules/database"
  resource_group_name = azurerm_resource_group.modularized_app.name
  project_name = var.project_name
  azure_region = var.azure_region
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module storage {
  source    = "./modules/storage"
  resource_group_name = azurerm_resource_group.modularized_app.name
  project_name = var.project_name
  azure_region = var.azure_region
}

module web {
  source = "./modules/web"
  resource_group_name = azurerm_resource_group.modularized_app.name
  project_name = var.project_name
  azure_region = var.azure_region
  database_connection_string = module.database.database_connection_string
  storage_container_sas = module.storage.storage_container_sas_url_query_string
}