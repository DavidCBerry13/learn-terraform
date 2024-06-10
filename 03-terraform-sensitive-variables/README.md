# 03 - More Complex App

This example represents a more complex app-a web app and a database togehter.  This introduces a couple of new concepts:

- We need to set a username and password for the database.  These need to be treated as application secrets
- We need to give the web app the connection string for the database

In a future example, I will use a managed identity which is a more secure way to access a database from a web app.  But for this example, I am using a username password combo as this demonstrates some important conepts in Terraform.

## Variables Containing Sensitive Data

Variables for usernames, passwords, api keys, and other user secrets should be marked with as `sensitive = true` in their definition.

```terraform
variable "db_password" {  
  description = "Database password"
  type        = string  
  default     = null
  sensitive   = true
}
```

Marking the variable as sensitve will

- Prevent Terraform from printing its value out in the console
- Prevent Terraform from outputing this value

However, the sensitve values will still appear in the `.tfstate` file as they are conidered part of the configuration.  As such, it is important to not check the `tfstate` file into source control and make sure to keep it secure.

## Passing Variables to Terrafom

There are multiple ways to pass variable values into your Terraform project during the *apply* phase.

- By default, Terraform will read files with the names of `terraform.tfvars` or `*.auto.tfvars`
- You can pass a variable on the command line with the `-var` switch, for example `-var azure-region=centralus`
- You can pass a variable file using the `-var-file` switch, for example `-var-file secrets.tfvars`

It is important to note that `.tfvars` files should never be checked into source control as they may contain secret values.  The standard `.gitignore` file for Terraform excludes `.tfvars` files by default.

In this project, I have used a file called `secrets.tfvars` for my sensitive values.  Therefore my `terraform apply` commadn will look like

```bash
terraform apply -var-file secrets.tfvars
```

If you are running `terraform plan`, you must also inclde the `secrets.tfvars` file otherwise you will receive an error.

```bash
terraform plan -var-file secrets.tfvars
```