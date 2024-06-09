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

This workspace also contains a file named `variables.tf` which defines the input variables tis workspace will accept.  Using variables provides a way to parameterize your configurations.

Using variables is described in detail in the Terraform docs in the article [Customize Terraform configuration with variables](https://developer.hashicorp.com/terraform/tutorials/cli/variables).

This workspace defines two variables, once for the project name which gets used to name the resources and one for the Azure region.  These are references in the `main.tf` file using the syntax *var.variable_name*.

## Outputs

The file `outputs.tf` defines values you want to output from your configuration.  Sometimes when resources are created, you need to output those values so you can see them.  In this case, I am outputing the default_hostname from the webapp for I know what the URL of the site that was just created was.
