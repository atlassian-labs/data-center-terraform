# Installation 

!!! info "List of supported Atlassian Data Center products."
    At this time **Bamboo DC** is the only supported product by this project. We will work hard to include more Data Center products into this project.

## 1. AWS Configuration
Configure your AWS credentials with admin access. [AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## 2. Clone the project
Clone the Terraform for Atlassian DC Products into your local 
```
git clone https://github.com/atlassian-labs/data-center-terraform.git && cd data-center-terraform
```

## 3. Configure the infrastructure
Configure the infrastructure for the selected products. 
Open configuration file using a text editor and configure the infrastructure as required 
(See [configuration](CONFIGURATION.md) page).  

!!! info "Where to find the configuration file?"
    The Terraform project uses `config.auto.tfvars` from root to configure the infrastructure in install and uninstall process by default. 
       
!!! tip "How to use a different configuration file?"
    You can use any other customised file with the same format as default config file to override it. 
    This could be done by making a copy of `config.auto.tfvars` and use it as a template to define the configuration of your infrastructure. 
    
    Then use this file to override the default config file in install and uninstall steps. 
    
!!! Warning "Make sure you use the same configuration file in both install and uninstall of the infrastructure."  
    If you have more than one environment, make sure to manage the config file of each environment separately. 
    When you need to clean up the environment use the same config file that is being used to create the environment.   

## 4. Install the infrastructure and product        
When based on your environment the config file is configured then you are ready to start installation process. 
Installing process will provision the required infrastructure for the configured environment and will install the selected products. 

Terraform handles creating and managing the infrastructure. 
To keep track of the current state of the resources and manage any further change, terraform creates a S3 bucket to store the current state of the environment.
Also, it creates a dynamodb table to handle to manage lock the environment during installation, cleanup, and upgrade to prevent modifying by more than one process at the time.
This process is part of installation and no extra step is needed to take. 
 
The installation script is located in `pkg/scripts` folder of the project.

Usage:  `./pkg/scripts/install.sh [-c <config-file] [-h]`

As mentioned before, the default config file is `config.auto.tfvars` and located in root of the project. 
Running install script with no parameter will use the default config file to provision the environment. 

You may use a different file with the same format to handle more than one environment but remember when you want to uninstall and cleanup the environment you need use the same config file. 

!!! info "Supported Atlassian Data Center products."
    At this time **Bamboo** is the only supported product.


=== "Using the default config file"

    To provision the infrastructure using default config file run:
        ```shell
        ./pkg/scripts/install.sh
        ```
   
=== "Using other config file"
   
    If you need to use a different config file other than the defualt one then first create and configure your config file and then run: 
            
    ``` shell
    ./pkg/scripts/install.sh -c <your-config_file>
    ```  
    
!!! info "How to run the product after installation?"    
    When the installation process finishes successfully, you can find some detailed information about the infrastructure on your console including the endpoint url (`product_urls`/`load_balancer_hostname`) to open the product on your browser and more.      