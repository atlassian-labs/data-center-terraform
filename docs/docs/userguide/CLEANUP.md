# Uninstall and Cleanup 

!!! warning "You may lose valuable data in the cleanup process"
    Before you start uninstalling the products and infrastructure make sure you have backed up all data you may need. 
    
    After uninstall you have no access to the product data including local volume, shared volume, database, and Terraform state information. 


To uninstall the products and clean up the infrastructure first make sure you made a backup from all application data you may need.
Uninstall will **permanently delete** the database, shared home, local home, and Terraform state data.

If you wish to uninstall just one product please **do not** proceed with the uninstall process and see [Configuration](CONFIGURATION.md) instead. 

!!! warning "Make sure you have made backup of the product data."
    All product data will be **permanently deleted** after uninstall.

Please note the uninstall will destroy your data so make sure you have the latest backup of your data before you start cleaning the infrastructure.
You may proceed when you are ready to uninstall. 

```shell
./uninstall.sh [-t] [-c <config.tfvars>]
```
Uninstall command removes the infrastructure but terraform state files will remain after the process. 
You should use switch `-t` if you need to cleanup the terraform state as well.

As you can manage multiple environments, you need to define the environment to uninstall. 
This is possible by using the same config file that you used to create the environment.  
If you have used the default configuration file (`config.tfvars`) from the root folder of the project, then you may simply use the following command:

```shell 
./uninstall.sh
```

If you used a custom-defined config file when the infrastructure is installed, then you need to run the following command using the same config file you used in the install command instead:
```shell
./uninstall.sh -c <custom-config-file>
```

Uninstall will remove the products and all Atlassian Data Center infrastructure by default. 
Terraform state files will be remain after uninstall unless you force removing it by adding switch `-t` in uninstall command. 

!!! tip "Do you want to delete the terraform state after removing environment?"
    If you want to clean up the terraform state files and dynamodb lock table then use the switch `-t`:
    ```shell 
    ./uninstall.sh -t [-c <custom-config-file>]
    ```
