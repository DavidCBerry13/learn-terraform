terraform {
  required_version = ">= 1.8.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

provider "azurerm" {
  features {}
}

provider "cloudinit" {
  
}

// ----------------------------------------------------------------------------
// Variables
// ----------------------------------------------------------------------------

variable "project_name" {
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
  default     = "tf-multiple-vms"
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}

variable "admin_user_name" {
  description = "Name of the admin user that gets created on the VM"
  type        = string
  default     = "az-vm-admin"
}

variable "ssh_key_path" {
  description = "Path to the SSH public key to use for the vm admin user"
  type        = string
}

variable "vm_identifiers" {
description = "Identifiers assigned to each VM/NIC/Public IP"
type = list(string)
default = ["01", "02"]
}


// ----------------------------------------------------------------------------
// Outputs
// ----------------------------------------------------------------------------

output "public_ip" {
  value = [
    for ip in azurerm_public_ip.vm_public_ip : ip.ip_address
  ]
}


// ----------------------------------------------------------------------------
// Azure Resources
// ----------------------------------------------------------------------------

resource "azurerm_resource_group" "resource_group" {
  name     = var.project_name
  location = var.azure_region
}

data "azurerm_platform_image" "vm_image" {
  location  = azurerm_resource_group.resource_group.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
}

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/cloud-init-config/cloud-config.yaml")
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-${var.project_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet_internal" {
  name                 = "snet-${var.project_name}-internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network.address_space[0], 8, 2)]
}



resource "azurerm_public_ip" "vm_public_ip" {
  for_each            = toset(var.vm_identifiers)
  name                = "ip-${var.project_name}-${each.value}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_network_interface" {
  for_each            = toset(var.vm_identifiers)
  name                = "nic-${var.project_name}-${each.value}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[each.value].id
  }
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  for_each            = toset(var.vm_identifiers)
  name                = "vm-${var.project_name}-${each.value}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_B2s"
  admin_username      = var.admin_user_name
  network_interface_ids = [
    azurerm_network_interface.vm_network_interface[each.value].id,
  ]

  admin_ssh_key {
    username   = var.admin_user_name
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.vm_image.publisher
    offer     = data.azurerm_platform_image.vm_image.offer
    sku       = data.azurerm_platform_image.vm_image.sku
    version   = data.azurerm_platform_image.vm_image.version
  }

  custom_data = data.cloudinit_config.config.rendered
}