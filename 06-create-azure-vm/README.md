# Creating an Azure VM

Even though it is preferable to use Platform as a Service (PaaS) services, there are still many instances where a Virtual Machine is needed.  This simple example will create a VM so there is an example of how to do so with Terraform in this repo.  Some of the interesting concepts in this example include:

- Use of a data source to get the VM image to use for the machine
- Use of [Cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) to initialize the virtual machine
- Use of an ssh key to login to a Linux VM

This code is largely based on the YouTube video [Using Terraform with Azure](https://www.youtube.com/watch?v=6oJzsBl_-so&t=1211s)

## Data sources

One of the features of Terraform is the ability to use data sources.  This is when you need to query some data from the provider in order to populate the value of a resource.  In this case, we are using a data source to find the VM image (the version of Linux) that is being installed.

Azure VM images have multiple properties.

- **Architecture** - Usually something like x64, though other values are possible
- **Publisher** - The publisher of the image, like *Microsoft*, *Canonical*, *Debian*, or *SUSE*
- **Sku** - Typically the version of the OS
- **Offer** - Sort of like a name for the image.  Sometimes has info about what is on the image

To see a list of images, use the Azure CLI `az vm image list` command like follows

```bash
az vm image list --output table --publisher Canonical --architecture x64
```

Once you have the Publisher, Sku, and Offer values, you can populate the [azurerm_platfrom_image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/platform_image) block in your Terraform *main.tf* file like follows:

```hcl
data "azurerm_platform_image" "vm_image" {
  location  = azurerm_resource_group.resource_group.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
}
```

This pulls back the image info for the specified paramters from the Azure Provider.  This block can then be references like a resource when you go to specify the image detaisl in the definition of your VM.

```hcl
  source_image_reference {
    publisher = data.azurerm_platform_image.vm_image.publisher
    offer     = data.azurerm_platform_image.vm_image.offer
    sku       = data.azurerm_platform_image.vm_image.sku
    version   = data.azurerm_platform_image.vm_image.version
  }
```

## Cloud Init

[Cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) is a popular way to initialize Linux virtual machines.  Azure supports the use of cloud-init through the use of a `custom_data` attribute on the virtual machine.  Whether using the Azure Portal, the Azure CLI, or Terraform, you can pass a cloud-init file to the custom_data paramater and Azure will execute that file when the VM starts the first time to configure the VM.  

To use cloud-init with Terraform, you want to make use of the [cloudinit provider](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config).  This provider can read cloud-init files from disk and encode them appropriately to be understood by the cloud provider (in this case Azure).

First, *cloudinit* is added to the *versions.tf* file so Terraform knows it needs to load the provider.  This means the *versions.tf* file now has both the *azurerm* and *cloudinit* providers specified.

```json
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
```

Next, add an empy configuration block to the *providers.tf* file as the cloudinit provider does not require any configuration.

```json
provider "cloudinit" {
  
}
```

Next, you want to have a cloud-init file in you project directory.  There are several examples on the [cloud-init docs page](https://cloudinit.readthedocs.io/en/latest/reference/examples.html).  Cloud-init files are yaml files, but you can also include shell scripts as well.

The example I am using creates a very simple Node.js application and has it listen on port 3000.  This file is stored in the [cloud-init-config](./cloud-init-config/cloud-config.yaml) of the project.

Next, use a data block to read in the cloud-init contents into Terraform.  For Azure, gzip and base64_encode both need to be set to true.  Note also how the built-in variable `${path.module}` is used to reference the module directory.

```hcl
data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/cloud-init-config/cloud-config.yaml")
  }
}
```

Then, include `custom_data` parameter in the virtual machine definition and point at the cloud-init data you just defined.

```hcl
custom_data = data.cloudinit_config.config.rendered
```

Note that cloud-init may continue to run for a bit after the VM comes up so cloud-init can do its configuration

## SSH Login

On Linux machines, it is preferred to use an SSH key pair to authenticate to a server rather than a password as a key pair are considered more secure.  When creating a VM using Terraform, you can tell the Azure VM to use an SSH key for authentication rather than a password.

To do this, you will first need to have an SSH keypair on your machine.  If you do not have one, you can generate a key pair by using the `ssh-keygen` command.

```PowerShell
ssh-keygen -t rsa
```

The `-t` option specifies the algorithm to use.  The available choices are DSA, RSA, ECDSA, or Ed25519, however, Azure/Terraform only supports RSA, so you need to create/have an RSA key.

This will prompt you where to put the key (typically in your .ssh directory).  Be careful not to overwrite any existing keys otherwise you will not be able to login to those servers any more.  You will also be prompted to enter a passphrase for the private key.

In the Virtual Machine definition, you then include an `admin_ssh_key` block to specify the username and the ssh key.  The `public_key` property needs to point at the *.pub* file.  Use the `file` function to read in the key.

```hcl
admin_ssh_key {
  username   = "vmadmin"
  public_key = file("C:/Users/username/.ssh/id_rsa.pub")
}
```

You can also put the path to the *.pub* file into a variable.  Then the `admin_ssk_key` block looks like this.  Note that you still need to wrap the variable with the file path in a `file()` function.

```hcl
admin_ssh_key {
  username   = "vmadmin"
  public_key = file(var.ssh_key_path)
}
```

Once the VM is created with the `terraform apply` command, you can get the IP address by looking in the Azure Portal or by using the `terraform output` command.

```bash
terraform output public_ip
```

Then you can login to the VM using `ssh`.  You will need to provide the passphrase for your private key.

```bash
ssh vmadmin@\<ip-address\>
```

## Resources

- [Key-based authentication in OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)