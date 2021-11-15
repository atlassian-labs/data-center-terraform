# Installation 

1. Configure your AWS credentials with admin access. [AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
2. Clone the Terraform for Atlassian DC Products into your local 
    ```
    git clone https://github.com/atlassian-labs/data-center-terraform.git && cd data-center-terraform
    ```
3. Open `config.auto.tfvars` file using a text editor and configure the infrastructure as required 
    (See [configuration](CONFIGURATION.md) page).  
       
    !!! tip "How to override the default configuration file?"
        You can Make a copy of `config.auto.tfvars` and use it to override the default one. This could be useful for test
         purposes when you need to make some modification on your config but still want to keep the content of 
         the default config data. In this case you should use the following command in step 4:
        
        ``` shell
        ./pkg/scripts/install.sh -c <config_file>
        ```   
        
4. Run the following script to create the infrastructure and install the products 
(at this point only 'Bamboo' is supported):
    ```shell
    ./pkg/scripts/install.sh
    ```
   
