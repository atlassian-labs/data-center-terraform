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
./uninstall.sh [-c <config_file>] [-h] [-f] [-s]"
```

The following options are available:

- `-c <config_file_path>` - Pass a custom configuration file to uninstall the environment provisioned by it.
- `-f` - skip manual confirmation of the environment deletion."
- `-s` - skip refresh when running terraform destroy"
- `-h` - provides help to how executing this script."

!!!info "Uninstallation using default and custom configuration files"

    If you used the default configuration file (`config.tfvars`) from the root folder of the project, run the following command:

    ```shell
    ./uninstall.sh
    ```

    Alternatively if you used a custom configuration file to provision the infrastructure, run the following command using the same configuration file:

    ```shell
    ./uninstall.sh -c my-custom-config.tfvars
    ```

