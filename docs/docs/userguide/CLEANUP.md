# Uninstall and Cleanup 

!!! warning "You may lose valuable data in the cleanup process"
    Before you start uninstalling the products and infrastructure make sure you have backed up all data you may need. 
    
    After uninstall you have no access to the product data including local volume, shared volume, database, and Terraform state information. 


To uninstall the products and clean up the infrastructure first make sure you made a backup from all application data you may need.
Uninstall will **permanently delete** the database, shared home, local home, and Terraform state data.

If you wish to uninstall just one product please **do not** proceed with the uninstall process and see [Configuration](CONFIGURATION.md) instead. 

!!! warning "Make sure you have made backup of the product data."
    All product data will be **permanently deleted** after uninstall.

You may proceed when you are ready to uninstall:

In order to uninstall the products and cleanup the infrastructure, you need to have the same configuration file that you used to install the infrastructure. 
If you have used the default configuration file (`config.auto.tfvars`) from the root folder of the project, then you may simply use the following command:

```shell 
./pkg/scripts/uninstall
```

If you used a custom config file to install the infrastructure then you need to run the following command instead:
```
./pkg/scripts/uninstall -c <custom-config-file>
```

This will remove the products and all Atlassian Data Center infrastructure including Terraform state which were created by the installing process. 

!!! tip "Do you want to keep the terraform state?"
    If you want to keep the terraform state files and dynamodb lock table then use the switch `-s`:
    ```shell 
    ./pkg/scripts/uninstall -s [-c <custom-config-file>]
    ```
