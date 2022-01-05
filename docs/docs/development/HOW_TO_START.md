# How to start development

Here's how to get started with contributing to the [Data Center Terraform](https://github.com/atlassian-labs/data-center-terraform) project.

## Requirements

Make sure that your development environment is configured with the following tools:

1. [Terraform](#terraform)
2. [Helm v3.3 or later](#helm)
3. [AWS CLI](#aws-cli)

### Terraform

This project uses Terraform to create and manage the Atlassian Data Center infrastructure on AWS for use with supported Data Center products.

1. Check if Terraform is already installed by running the following command:

    ```shell
    terraform version
    ```

2. If Terraform is not installed, install it by following the [official instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### Helm

Make sure that Helm v3.3 or later is installed on your machine.

1. Check if Helm v3.3 or later is already installed by running the following command:

    ```shell
    helm version --short
    ```

3. If Helm is not installed or you're running a version lower than 3.3, install Helm by following the [official instructions](https://helm.sh/docs/intro/install/){.external}.

### AWS CLI

We recommend using AWS CLI version 2.

1. Check if AWS CLI version 2 is already installed by running the following command:
    
    ```shell
    aws --version
    ```

2. If the AWS CLI is not installed or you're running version 1, install AWS CLI version 2 by following the [official instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html){.external}.

## Clone the project repository

Clone the [Data Center Terraform](https://github.com/atlassian-labs/data-center-terraform) repository locally:

```shell
git clone git@github.com:atlassian-labs/data-center-terraform.git && cd data-center-terraform
```

## GitHub pre-commit hook

Configure pre-commit and TFLint to maintain good quality of the committed Terraform code.

1. Install [pre-commit](https://pre-commit.com/).

    For example: `brew install pre-commit`

2. In a terminal, change the directory to the repository root and run `pre-commit install`.
3. Install [TFLint](https://github.com/terraform-linters/tflint).

    For example: `brew install tflint`

5. Add the following content to `.tflint.hcl`:

    ```hcl
    plugin "aws" {
        enabled = true
        version = "0.5.0"
        source  = "github.com/terraform-linters/tflint-ruleset-aws"
    }
    ```

6. Initialize TFLint:

    ```shell
    tflint --init
    ```