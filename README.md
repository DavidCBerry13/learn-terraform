# Learn Terraform

A repository used for learning and experimenting with Terraform.  Most of the examples use Azure as a target.



## Common Terraform Commands

| Command             | Description | Docs |
|---------------------|-------------|------|
| `terraform init`    | Initialzes a Terraform workspace.  This command must be run at least once in the primary directory of the workspace and will need to be run again if you add or update any providers to your Terraform project. | [Docs](https://developer.hashicorp.com/terraform/cli/commands/init) |
| `terraform plan`    | Creates an execution plan so you can preview the changes that Terraform is going to make.  Running `terrafrom plan` also acts as a linter for your Terraform files. | [Docs](https://developer.hashicorp.com/terraform/cli/commands/plan) |
| `terraform apply`   | Applies (executes) a Terraform configuration.  This is when the resources actually get created or modified (for example creating resources in Azure or AWS) | [Docs](https://developer.hashicorp.com/terraform/cli/commands/apply) |
| `terraform destroy` | Removes the resources specified in the Terraform configuration.  This command is called to clean up and remove the resources when you are done.  This is important with cloud resources where you are incurring costs by having the resources running | [Docs](https://developer.hashicorp.com/terraform/cli/commands/destroy) |





## Resources

- [Best Practices for using Terraform - Google Cloud](https://cloud.google.com/docs/terraform/best-practices-for-terraform)