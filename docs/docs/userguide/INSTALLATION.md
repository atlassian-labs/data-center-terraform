# Installation

This guide describes how to provision the cloud environment infrastructure and install Atlassian Data Center products in a Kubernetes cluster running on AWS.

## 1. Set up AWS security credentials

Set up a user with an administrator IAM role. See [Configuration basics — AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html){.external}.

## 2. Clone the project repository

Clone the `data-center-terraform` project repository from GitHub:

```shell
git clone -b 2.9.1 https://github.com/atlassian-labs/data-center-terraform.git && cd data-center-terraform
```

## 3. Configure the infrastructure

Details of the desired infrastructure to be provisioned can be defined in `config.tfvars` located in the root level of the cloned project. Additional details on how this file can/should be configured can be found in the [Configuration guide](configuration/CONFIGURATION.md).

??? info "Configuration file location?"
    By default, Terraform uses `config.tfvars` located in the root level of the project.
       
??? tip "Can I use a custom configuration file?"
    You can use a custom configuration file, but it must follow the same format as the default configuration file. You can make a copy of `config.tfvars`, renaming the copy and using `config.tfvars` as a template to define your own infrastructure configuration.

??? tip "How to install more than one DC product?"
    More than one DC products can be provisioned to the same cluster. See the [Configuration guide](configuration/CONFIGURATION.md#products) for more details.
    You can also install DC products to an existing environment by adding the [product](configuration/CONFIGURATION.md) in the environment's config file and re-run the [install](INSTALLATION.md) command.

??? Warning "Use the same configuration file for uninstallation and cleanup"  
    If you have more than one environment, make sure to manage the configuration file for each environment separately. When cleaning up your environment, use the same configuration file that was used to create it originally.

## 4. Run the installation script

Based on how `config.tfvars` has been configured the installation script will 

1. Provision the environment and infrastructure 
2. Install the selected DC product(s) 

Installation is fully automated and requires no user intervention. Terraform is invoked under the hood which handles the creation and management of the Kubernetes infrastructure.


??? info "Terraform deployment details"
    To keep track of the current state of the resources and manage changes, Terraform creates an [AWS S3 bucket](https://aws.amazon.com/s3/){.external} to store the current state of the environment. An [AWS DynamoDB](https://aws.amazon.com/dynamodb/) table is created to handle the locking of remote state files during the installation, upgrade, and cleanup stages to prevent the environment from being modified by more than one process at a time. 

    The installation script, `install.sh`, is located in the root folder of the project.

Usage:  

```shell
./install.sh [-c <config_file_path>] [-h]
```

The following options are available:

- `-c <config_file_path>` - Pass a custom configuration file when provisioning multiple environments
- `-h` - Display help information

!!! info "Using the same cloned repository to manage more than one environment"

    If the repository has already been used to deploy an environment, and that environment is still active, i.e. hasn't been uninstalled yet, 
    deploying a new environment using install.sh will get a prompt with following message: 

    ```shell
    Do you want to copy existing state to the new backend? Pre-existing state was found while migrating 
    the previous "s3" backend to the newly configured "s3" backend. An existing non-empty state already 
    exists in the new backend. The two states have been saved to temporary files that will be removed 
    after responding to this query. 
    Previous (type "s3"): /var/folders/vm/sz46pmw94f3f8nrvzyqhwmx00000gn/T/terraform3661306827/1-s3.tfstate 
    New (type "s3"): /var/folders/vm/sz46pmw94f3f8nrvzyqhwmx00000gn/T/terraform3661306827/2-s3.tfstate 
    Do you want to overwrite the state in the new backend with the previous state? Enter "yes" to copy 
    and "no" to start with the existing state in the newly configured "s3" backend.

    Enter a value:
    ```

    This will happen everytime when you switch between different active environments. Since environemnts are independent, answer '*NO*' to continue.  
    If you answered Yes, Terraform will then use the state of active environment to plan and deploy new environment, which will pollute the state of both environments, and end up to an error state.  
    Check [troubleshoting](../troubleshooting/TROUBLESHOOTING.md) guide if you accidentally answered Yes. 

Running the installation script with no parameters will use the default configuration file to provision the environment. 

!!!info "Installation using default and custom configuration files" 

    Running the installation script with no parameters will use the default configuration file (`config.tfvars`) to provision the environment:

    ```shell
    ./install.sh
    ```

    Alternatively a custom configuration file can be specified as follows:

    ```shell
    ./install.sh -c my-custom-config.tfvars
    ```

??? help "How do I find the service URL of the deployed DC product?"    
    When the installation process finishes successfully detailed information about the infrastructure is printed to `STDOUT`, this includes the `product_urls` value that can be used to launch the product in the browser.      

??? help "Where do I find the database `username` and `password`?"
    The database master `username` and `password` for each product is dynamically generated by Terraform and saved in a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/){.external} within the product `namespace`.

    To access the database username and password, run the following commands:
    ```
    DB_SECRETS=$(kubectl get secret <product-name>-db-cred -n atlassian -o jsonpath='{.data}')
    DB_USERNAME=$(echo $DB_SECRETS | jq -r '.username' | base64 --decode)
    DB_PASSWORD=$(echo $DB_SECRETS | jq -r '.password' | base64 --decode)
    ``` 

    This saves the decoded username and password to the `$DB_USERNAME` and `$DB_PASSWORD` environment variables respectively.

## Uninstall 
The deployment and all of its associated resources can be un-installed by following the [Uninstallation and cleanup](CLEANUP.md) guide.
