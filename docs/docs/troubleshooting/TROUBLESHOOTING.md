# Troubleshooting tips

This guide contains general tips on how to investigate an application deployment that doesn't work correctly.

??? tip "How do I uninstall an environment using a different Terraform configuration file?" 
  
    **Symptom**

    If you try to uninstall an environment by using a different configuration file than the one you used to install it or by using a different version of the code, you may encounter some issues during uninstallation. In most cases, Terraform reports that the resource cannot be removed because it's in use.
    
    **Solution**

    Identify the resource and delete it manually from the AWS console, and then restart the uninstallation process. Make sure to always use the same configuration file that was used to install the environment. 



??? tip "How do I deal with persistent volumes that do not get removed as part of the Terraform uninstallation?"
    **Symptom**

    Uninstall fails to remove the persistent volume.
    ```shell
    Error: Persistent volume atlassian-dc-bamboo-share-home-pv still exists (Bound)
    
    Error: context deadline exceeded
    
    Error: Persistent volume claim atlassian-dc-bamboo-share-home-pvc still exists with 
    ```
    **Solution**

    If a bamboo pod termination stalls, it will block pvc and pv deletion. 
    To fix this problem we need to terminate product pod first and run uninstall command again.
    ```shell
    kubectl delete pod <bamboo-pod> -n bamboo --force
    ```
    To see the stalled Bamboo pod name you can run the following command:
    ```shell
    kubectl get pods -n bamboo 
    ```

??? tip "How do I deal with suspended AWS Auto Scaling Groups during Terraform uninstallation?"

    **Symptom**
    
    If for any reason Auto Scaling Group gets suspended, AWS does not allow Terraform to delete the node group. In cases like this the uninstall process gets interrupted with the following error:
    
    ```shell
    Error: error waiting for EKS Node Group (atlas-ng-second-test-cluster:appNode) to delete: unexpected state 'DELETE_FAILED', wanted target ''. last error: 2 errors occurred:
        * i-06a4b4afc9e7a76b0: NodeCreationFailure: Instances failed to join the kubernetes cluster
        * eks-appNode-3ebedddc-2d97-ff10-6c23-4900d1d79599: AutoScalingGroupInvalidConfiguration: Couldn't terminate instances in ASG as Terminate process is suspended
    ```
    
    **Solution**
    
    Delete the reported Auto Scaling Group in AWS console and run uninstall command again. 

??? tip "How do I deal with Terraform AWS authentication issues during installation?"

    **Symptom**
    
    The following error is thrown:
    
    ```shell
    An error occurred (ExpiredToken) when calling the GetCallerIdentity operation: The security token included in the request is expired
    ```
    
    **Solution**
    
    Terraform cannot deploy resources to AWS if your security token has expired. Renew your token and retry.

??? tip "How do I deal with Terraform state lock acquisition errors?"

    If user interrupts the installation or uninstallation process, Terraform won't be able to unlock resources. In this case, Terraform is unable to acquire state lock in the next attempt.
       
    **Symptom**
    
    The following error is thrown:
    
    ```shell
    Acquiring state lock. This may take a few moments...
    
     Error: Error acquiring the state lock
    
     Error message: ConditionalCheckFailedException: The conditional request failed
     Lock Info:
       ID:        26f7b9a8-1bef-0674-669b-1d60800dea4d
       Path:      atlassian-data-center-terraform-state-xxxxxxxxxx/bamboo-xxxxxxxxxx/terraform.tfstate
       Operation: OperationTypeApply
       Who:       xxxxxxxxxx@C02CK0JYMD6V
       Version:   1.0.9
       Created:   2021-11-04 00:50:34.736134 +0000 UTC
       Info:
    ```
    
    **Solution**
    
    Forcibly unlock the state by running the following command:
    
    ```shell 
    terraform force-unlock <ID>
    ```
    
    Where `<ID>` is the value that appears in the error message.
    
    There are two Terraform locks; one for the infrastructure and another for Terraform state. If you are still experiencing lock issues, change the directory to `./modules/tfstate` and retry the same command.

??? hint "How do I deal with Pre-existing state in multiple environment?"

    If you start installing a new environment while you already have an active environment installed before, you should NOT use the pre-existing state. 
    
    The same scenario when you want to uninstall a non-active environment.     
    
    !!! help "What is active environment?"
         Active environment is the latest environment you installed or uninstalled.
            
    !!! hint "Tip"
        Answer '**NO**' when you get a similar message during installation or uninstallation:
        ```shellscript
        Do you want to copy existing state to the new backend? Pre-existing state was found while migrating 
        the previous "s3" backend to the newly configured "s3" backend. An existing non-empty state already 
        exists in the new backend. The two states have been saved to temporary files that will be removed 
        after responding to this query. 
        
        Do you want to overwrite the state in the new backend with the previous state? Enter "yes" to copy 
        and "no" to start with the existing state in the newly configured "s3" backend.
        
        Enter a value:
        ```
         
    **Symptom**
    
    Installation or uninstallation break after you chose to use pre-existing state. 
    
    
    **Solution**
    
    1. Clean up the project before proceed. In root directory of the project run:
    ```shell
    ./scripts/cleanup.sh -s -t -x -r .
    terraform init -var-file=<config file>
    ```
    3. Then re-run the install/uninstall script.
    

??? tip "How do I deal with `Module not installed` error during uninstallation?"

    There are some Terraform specific modules that are required when performing an uninstall. These modules are generated by Terraform during the install process and are stored in the `.terraform` folder. If Terraform cannot find these modules, then it won't be able perform an uninstall of the infrastructure. 

    **Symptom**
    
    ```shell
    Error: Module not installed
    
      on main.tf line 7:
       7: module "tfstate-bucket" {
    
    This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
    ```
    
    
    **Solution**
    
    1. In the root directory of the project run:
    ```shell
    ./scripts/cleanup.sh -s -t -x -r .
    cd modules/tfstate
    terraform init -var-file=<config file>
    ```
    2. Go back to the root of the project and re-run the `uninstall.sh` script.
    

??? tip "How do I deal when remote agents are offline after provisioning the Bamboo DC?"
       
    **Symptom**
    
    The remote agents are installed but remain offline after installation. 
       
    **Solution**
    
    1. Open the Bamboo application in the browser and log in as _Administrator_. 
    2. Go to `Agents` page and select `Agent authentication` tab.
    3. Select `All` and press `Approve access` button. 
    4. Wait until all remote agents get online.


