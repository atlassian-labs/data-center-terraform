# Uninstallation and Cleanup 

This guide describes how to uninstall all Atlassian Data Center products and remove cloud environments 

!!! warning "The uninstallation process is destructive"
    The uninstallation process will **permanently delete** the local volume, shared volume, and the database. Terraform state information can also optionally be removed.

    Before you begin, make sure that you have an up-to-date backup available in a secure location. 

The uninstallation script is located in the root folder of the project directory.

Usage:

```shell
./uninstall.sh [-t] [-c <config.tfvars>]
```

The following options are available:

- `-t` - Delete Terraform state files
- `-c <config_file_path>` - Pass a custom configuration file to uninstall the environment provisioned by it.

!!!info "Uninstallation using default and custom configuration files"

    If you used the default configuration file (`config.tfvars`) from the root folder of the project, run the following command:

    ```shell
    ./uninstall.sh
    ```

    Alternatively if you used a custom configuration file to provision the infrastructure, run the following command using the same configuration file:

    ```shell
    ./install.sh -c my-custom-config.tfvars
    ```


### Removing Terraform state files

By default, the script does not remove Terraform state files. If you want to remove Terraform state files, run the uninstallation script with the `-t` switch:

```shell 
./uninstall.sh -t -c <config_file_path>
```

!!! warning "`-t` flag will remove the S3 Bucket that the Terraform state file is located"
    This means if you have multiple environments provisioned under same AWS account and region, you will lose the track of them.

    Use this flag only if you are sure that there is no other environment left in your region and account.