# Multiple VMs in Terraform

This example created multiple VMs in Azure.  It is intended to demonstrate working with lists and looping contexts in Terraform.  This example does not demonstrate load balancing, only creating multiple VMs.  This example also puts all the code into a *main.tf* file for simplicity.

This example takes in a variable `vm_identifiers`.  For each value in the list, a virtual machine (and its associated NIC card and public IP address) will be created.  The VM, NIC, and Public IP will all have the valie of the identifier appended onto the resource name (for example *vm-tf-multiple-vms-01* and *vm-tf-multiple-vms-02*)

```hcl
variable "vm_identifiers" {
description = "Identifiers assigned to each VM/NIC/Public IP"
type = list(string)
default = ["01", "02"]
}
```

In the *.tfvars* file, you could define your own list (and naming scheme) creating more or fewer VMs as required.

```hcl
vm_identifiers = ["WEB01", "WEB02", "WEB03", "WEB04"]
```

## Creating Multiple Resources

The point is that we don't want to create multiple resource blocks for VM 1, 2, 3, 4, etc.  This is where the [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) meta argument comes in.

First, we need to create multiple public ip addresses, one to be associated to each NIC card and ultimately to each Virtual Machine.  The `for_each` argument is included as the first parameter to the resource and specifies the array:

- The `for_each` does not have to be the first argument, but this is convention and helps identify that we are creating multiple resources.
- You do not have to use a `toset()` function, but this will filter out any duplicate names which would result in an error when you ran `terraform apply`
- You can grab the value using the `${each.value}` expression as shown in the name parameter.  This is useful to uniquely name the resources.

```hcl
resource "azurerm_public_ip" "vm_public_ip" {
  for_each            = toset(var.vm_identifiers)
  name                = "ip-${var.project_name}-${each.value}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}
```

Often times in Terraform, we have one resource that references another.  In this example, the NIC card references the public ip address.  That is, when you create the NIC card for the VM, you need to specify the id of the public IP address so you can create the NIC card.  Similarly, when you create the VM, you will need to specify the id of the NIC card associated with the VM.

When we create multiple resources like this, Terraform basically has a hashtable of the resources created.  The key will be the value of array.

Using this knowledge, we can lookup the appropriate id value.  In the example below, the `public_ip_address_id` parameter of the `ip_configuration` block references the public ip address using `azurerm_public_ip.vm_public_ip[each.value].id`.  The square brackets on the `vm_public_ip` resource tell Terraform to look up the public ip object associated with the current array value, represented as `[each.value]`.

```hcl
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
```

## Outputs

When you create multiple resources, they are in a hashtable (a map).  To get values out of the hashtable (like in an output block), you need to look over all the items in the hashtable and output what you want.

In this case, we want to get all the IP addresses back so we know the IPs of the VMs we created.

```hcl
output "public_ip" {
  value = [
    for ip in azurerm_public_ip.vm_public_ip : ip.ip_address
  ]
}
```

## Resources

- [Stack Overflow - modules + output from for_each](https://stackoverflow.com/questions/64989080/modules-output-from-for-each)
