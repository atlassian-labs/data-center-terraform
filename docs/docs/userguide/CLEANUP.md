# Uninstallation and Cleanup 

This guide describes how to uninstall all Atlassian Data Center products and remove cloud environments 

??? important "Do you want to install a DC product but still keep the common infrastructure and other installed products?"
    To uninstall one or more products without destroying the infrastructure, remove the [product names](configuration/CONFIGURATION.md#products) from environment's config file and re-run [install](INSTALLATION.md) command.

!!! warning "The uninstallation process is destructive"
    The uninstallation process will **permanently delete** the local volume, shared volume, and the database. Terraform state information can also optionally be removed.

    Before you begin, make sure that you have an up-to-date backup available in a secure location. 

The uninstallation script is located in the root folder of the project directory.

Usage:

```shell
./uninstall.sh [-t] [-c <config.tfvars>]
```

The following options are available:

- `-t` - Delete Terraform state files for all installed environment in the same region using the same AWS account.
- `-c <config_file_path>` - Pass a custom configuration file to uninstall the environment provisioned by it.

!!!info "Uninstallation using default and custom configuration files"

    If you used the default configuration file (`config.tfvars`) from the root folder of the project, run the following command:

    ```shell
    ./uninstall.sh
    ```

    Alternatively if you used a custom configuration file to provision the infrastructure, run the following command using the same configuration file:

    ```shell
    ./uninstall.sh -c my-custom-config.tfvars
    ```

### Removing Terraform state files

We create an AWS S3 bucket and DynamoDB table to store the Terraform state of the environments for each region. Without the state information, Terraform cannot maintain the infrastructure.
All environments installed in the same region share one S3 bucket to store the state files.  
By default, the uninstall script does not remove Terraform state files.  

!!! warning "Remove Terraform state files only if you confirm there is no other installed environment in the same region."
    If you have installed multiple environments using the same AWS account in the same region, you need to make sure all those environments are uninstalled before removing terraform state.
    
    After deleting the state files, **Terraform cannot manage the installed environments**.
    
If you have **no other environment installed in the same region**, you may want to remove the Terraform state files permanently. 
To remove Terraform state files permanently and delete AWS S3 bucket and DynamoDB, run the uninstallation script with the `-t` switch:

```shell 
./uninstall.sh -t -c <config_file_path>
```

