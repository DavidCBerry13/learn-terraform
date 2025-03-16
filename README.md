# Learn Terraform

A repository used for learning and experimenting with Terraform.  Most of the examples use Azure as a target.

## Terraform Files

A small Terraform project may only contain a single `main.tf` file.  However, most projects will contain multiple files.

| **File**            | **Description**                                                                                                                     |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `main.tf`           | Contains the resource definitions of the resources to create                                                                        |
| `versions.tf`       | Contains the `terraform` block.  Defines the required version of Terraform as well as any providers used by the project.            |
| `providers.tf`      | Contains configuration for the providers used by the project                                                                        |
| `variables.tf`      | Defines any input variables used by the project                                                                                     |
| `outputs.tf`        | Defines any output variables used in the project.  These are variables from one resource that you need to pass to another resource. |
| `*.tfvars`          | Contains values for variables.  These may include secret values (like passwords) so these are not checked into source control.      |
| `terraform.tfstate` | Stores the state of the project (as in the state of any resources created).  State can also be stored in the cloud.  This file can contain sensitive data like passwords and is not checked into source control. |
| `terraform.locl.hcl` | A system generated file that keeps track of what providers are used and the hashes |

## Common Terraform Commands

| Command             | Description | Docs |
|---------------------|-------------|------|
| `terraform init`    | Initialzes a Terraform workspace.  This command must be run at least once in the primary directory of the workspace and will need to be run again if you add or update any providers to your Terraform project. | [Docs](https://developer.hashicorp.com/terraform/cli/commands/init) |
| `terraform plan`    | Creates an execution plan so you can preview the changes that Terraform is going to make.  Running `terrafrom plan` also acts as a linter for your Terraform files. | [Docs](https://developer.hashicorp.com/terraform/cli/commands/plan) |
| `terraform apply`   | Applies (executes) a Terraform configuration.  This is when the resources actually get created or modified (for example creating resources in Azure or AWS) | [Docs](https://developer.hashicorp.com/terraform/cli/commands/apply) |
| `terraform destroy` | Removes the resources specified in the Terraform configuration.  This command is called to clean up and remove the resources when you are done.  This is important with cloud resources where you are incurring costs by having the resources running | [Docs](https://developer.hashicorp.com/terraform/cli/commands/destroy) |

## Reverse Engineering Existing Infrastructure to Terraform

The [Terraformer](https://github.com/GoogleCloudPlatform/terraformer?tab=readme-ov-file) tool can be used to reverse engineer existing infrastructure into TerraForm files.

## Resources

- [Beginners Tutorial to Terraform with Azure](https://www.youtube.com/watch?v=gyZdCzdkSY4)
- [HashiCorp Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [Best Practices for using Terraform - Google Cloud](https://cloud.google.com/docs/terraform/best-practices-for-terraform)