resource "azurerm_storage_account" "storage_acct" {
  name                     = replace(var.project_name, "/[^A-za-z0-9]/", "")
  resource_group_name      = var.resource_group_name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage_acct.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "sas" {
  connection_string = azurerm_storage_account.storage_acct.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name
  https_only        = true

  start  = timeadd(timestamp(), "-1h")
  expiry = timeadd(timestamp(), "43800h")

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}