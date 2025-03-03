# 02 - Using Terraform Variables

This workspace is meant to introduce a couple of concepts that will be important when working with larger projects.  These are

- Splitting your Terraform configuration into different `.tf` files
- Using variables in your Terraform configurations
- Outputting values from your Terraform configuration

## Splitting your Terraform configuration across files

Unlike the first example where everything was contained in `main.tf`, this workspace splits the following sections into different files:

- The `terraform` block is in the `versions.tf` file.
- The `providers` is in the `providers.tf` file

While the files could technically be named anything, `versions.tf` and `providers.tf` are convention in Terraform.

## Variables

This workspace also contains a file named `variables.tf` which defines the input variables tis workspace will accept.  Using variables provides a way to parameterize your configurations.  The contents of this file are as follows:

```hcl
variable "project_name" {
  description = "The name of the project/workload.  This is used to name the resources in Azure"
  type        = string
  default     = "learn-terraform"
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}
```

Using variables is described in detail in the Terraform docs in the article [Customize Terraform configuration with variables](https://developer.hashicorp.com/terraform/tutorials/cli/variables).

### Defining Variables

This workspace defines two variables:

- A variable named `project_name` which will be used in naming Azure resources
- A variable named `azure_region` specifying what region to create the resources in.

You can also define different types of variables such as string, number, bool, last, and map.

```hcl
variable "number_example" {
description = "An example of a number variable in Terraform"
type = number
default = 42
}

variable "list_example" {
description = "An example of a list in Terraform"
type = list
default = ["a", "b", "c"]
}
```

### Using Variables

To use a variable in a resource definition, use the syntax *var.variable_name*.

In the following resource definition, the `var.project_name` variable is used to name the resource group

```hcl
resource "azurerm_resource_group" "terraform_resource_group" {
  name     = var.project_name
  location = var.azure_region
}
```

Variables can also be used as part of an expression using a `${}` syntax inside of double quotes.  In the resource definition below, the name of the App Service Plan is contructed from combining  a prefix (`pln-`) with the name of the project-name from a variable.  The full string is `pln-${var.project_name}`

```hcl
resource "azurerm_service_plan" "terraform_app_service_plan" {
  name                = "pln-${var.project_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}
```

### Passing Variables to terraform

There are multiple ways to pass variable values into your Terraform project during the *apply* phase.

- By default, Terraform will read files with the names of `terraform.tfvars` or `*.auto.tfvars`
- Terraform will also look for any environment variables in the format of `TF_VAR_<variable_name>` and use those as input values
- You can pass a variable on the command line with the `-var` switch, for example `-var azure-region=centralus`
- You can pass a variable file using the `-var-file` switch, for example `-var-file secrets.tfvars`

It is important to note that `.tfvars` files should never be checked into source control as they may contain secret values.  The standard `.gitignore` file for Terraform excludes `.tfvars` files by default.

The *terraform.tfvars* file looks like this:

```text
project_name = "learn-terraform"
azure_region = "eastus2"
```

## Outputs

The file `outputs.tf` defines values you want to output from your configuration.  Sometimes when resources are created, you need to output those values so you can see them.  In this case, I am outputing the default_hostname from the webapp for I know what the URL of the site that was just created was.
