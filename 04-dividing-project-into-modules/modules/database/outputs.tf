output "database_connection_string" {
  value = "Server=tcp:sql-${var.project_name}.database.windows.net,1433;Initial Catalog=${var.db_name};Persist Security Info=False;User ID=${var.db_username};Password=${var.db_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}