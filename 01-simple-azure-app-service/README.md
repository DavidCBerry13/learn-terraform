# 01 - Simple Azure App Service Plan

This example is intended to be a first introduction to Terraform, a "Hello Terraform" if you will.  It introduces the structure of Terraform files and basic commands needed to create an App Service in Azure.

## Terraform Workspace and Files

A Terraform workspace is a directory that contains the files for a Terraform project.  A Terraform workspace will typically map to a workload.  That is, the workspace will define all of the infrastructure resources needed to run that workload.  

In this simple first example, we need 3 types of resources in Azure.

- A resource group
- An App Service Plan
- An App Service (also called the Web App)

Terraform workspaces always need to contain a `main.tf` file which serves as an entry point for Terraform.  In this simple example, all of the resource definitions are contained in this single `main.tf` file.  Future projects will use additional files, but to keep it simple, this example just uses the one file.

## `main.tf` file

Terraform files are formatted in a similar fashion to JSON.  The `main.tf` file contains multiple configuration blocks that are required to configure different aspects of your Terraform project.

### `terraform` block

The `terraform` block is the first configuration block specified in a file and has two primary purposes.

- Specify the version of Terraform to be used
- Specify any required *providers* and what version of the provider to use

A sample `terraform` configuration block is shown below.

```json
terraform {
    required_version = ">= 1.8.5"
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.107"
        }
    }
}
```

The `required_version` parameter in this config block specifies that you must be using Terraform version 1.8.5 or higher.

The `required_providers` block tells Terraform the [`azurerm`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) provider is required for this Terraform project.  It gives the location in the Terraform registry and specifies version 3.107.  The `~>` pins this provider to the *minor* version.  That is, it will allow patch level updates (e.g.3.107.1) but not updates to the major or minor version.

Hashicorp strongly reccomends that you specify versions for your Terrafrom projects as providers and Terraform itself change over time.  Specifying versions helps make sure your projects continue to work even as providers are updated.

### `providers` block

The `providers` block is where you can specify options for providers.  In this project, we are not specifying options, but in Azure, this is where you could specify what subscription id to use if you did not want to use your default subscription.

```terraform
provider "azurerm" {
  features {}
}
```

The different configuration options for the *azurerm* provider are [documented in the Terrafom registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block).

### `resource` blocks

Resource blocks are what create the actual resources in a Terraform project, in this case, resources in Azure.  The order that resources are listed in a Terraform file does not matter, but I find it useful to list resources in roughly the order they need to be created.

The first resource that is needed is an Azure Resource Group.

```terraform
resource "azurerm_resource_group" "terraform_resource_group" {
  name     = "vm-learn-terrafrom"
  location = "westus2"
}
```

The format of this block is as follows:

- The block starts with the keyword `resource`
- The second parameter is ("azurerm_resource_group") defines the type of resource to create.
- The third parameter is the identifier for this resource used in the terraform project (for example, when we have to refer to this resource from another resource in our configuration)
- Everything inside of the curly braces are the configuration parameters for the resource

The definitions of how to define a particular resource are documented in the Terraform Registry under the provider name.  This document shows the [options for an Azure Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).

The resource definition for the App Service Plan and Web App (App Service) are shown below.

```terraform
resource "azurerm_service_plan" "terraform_app_service_plan" {
  name                = "pln-learn-terraform"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}


resource "azurerm_linux_web_app" "terraform_linux_web_app" {
  name                = "web-learn-terrafrom"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  service_plan_id     = azurerm_service_plan.terraform_app_service_plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = false
  }
}
```

Note how thise resource blocks reference values in other resourc blocks.  For example, in the Linux web app, the `service_plan_id` field needs the value of the App Service Plan.  It is able to access this using `azurerm_service_plan.terraform_app_service_plan.id`.  This reference is specified in the format *resource-type.terraform-resource-name.value-name*.

