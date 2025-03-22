output "public_ip" {
  value = resource.azurerm_public_ip.vm_public_ip.ip_address
}