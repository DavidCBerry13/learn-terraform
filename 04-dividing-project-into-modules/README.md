# Dividing Projects into Madules

Once projects get to be a certain size, it is difficult to manage them all in a single `main.tf` file.  It makes sense to divide the project into logical modules, which this example demonstrates.

## Using Modules

- The convention is to create a `modules` directory and then create the individual directories for each module underneath it.  These directories should be named to for the part of the system they represent (for example, *web*, *network*, *database*, etc.)
- The top level directory with its `main.tf` module is defined as the main module.  Its primary job it to call the other modules and route data between those modules.
- For each module, you will define a `variables.tf` file that describes the variables that individual module requires
- You can also define a `outputs.tf` file that defines variables the module will pass back to the main module.  This allows a module to pass a value back (like a connection string for a database) to the main module so the main module can then pass it down to another module that needs it (like a web application)
- Terraform will create a `modules` directory unde the `.terraform` folders.  
  - For modules that you download from the Terraform Registry, they will be stored in this folder.
  - For local modules (like in this project), a symbolic link will be created from the `.terrafrom\modules` directory to the source of the local module
  - If you rename a local module, you will need to re-run `terraform init` so Terraform picks up the new changes.
  