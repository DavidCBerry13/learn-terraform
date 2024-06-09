output "website_url" {
  value = azurerm_linux_web_app.terraform_linux_web_app.default_hostname
}