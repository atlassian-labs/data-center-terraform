# Uninstallation and cleanup 

This guide describes how to uninstall all Atlassian Data Center products and remove cloud environments 

!!! warning "The uninstallation process is destructive"
    The uninstallation process will **permanently delete** the local volume, shared volume, database, and Terraform state information.

    Before you begin, make sure that you have an up-to-date backup available in a secure location. 

If you want to uninstall just one product, don't proceed with the uninstallation process and remove it from the configuration file instead. For more information, see [Configuration](CONFIGURATION.md). 

The uninstallation script is located in the `pkg/scripts` project directory.

Usage:

```shell
./uninstall.sh [-t] [-c <config.tfvars>]
```

The following options are available:

- `-t` - Delete Terraform state files
- `-c <config_file>` - Pass a custom configuration file when uninstalling multiple environments

Running the uninstallation script with no parameters will use the default configuration file. 



You can remove environments provisioned with the default configuration file as well as the ones provisioned with a custom configuration file.

## Removing environments provisioned with the default configuration file

If you used the default configuration file (`config.tfvars`) from the root folder of the project, run the following command:

```shell 
./uninstall.sh
```

## Removing environments provisioned with a custom configuration file

If you used a custom configuration file to provision the infrastructure, run the following command using the same configuration file:

```shell
./uninstall.sh -c <custom-config-file>
```

## Removing Terraform state files

By default, the script does not remove Terraform state files. If you want to remove Terraform state files, run the uninstallation script with the `-t` switch:

```shell 
./uninstall.sh -t [-c <custom-config-file>]
```
