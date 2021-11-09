# Installation 

1. Configure your AWS credentials with admin access. [AWS Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
2. Clone the Terraform for Atlassian DC Products into your local 
    ```
    `git clone https://github.com/atlassian-labs/data-center-terraform.git && cd data-center-terraform`
    ```
3. Run the following script to create the infrastructure (at this point only 'Bamboo' is supported):
    ```shell
    ./pkg/scripts/install.sh
    ```