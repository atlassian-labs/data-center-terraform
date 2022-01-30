# How to start development

A number of tools have been used for building this project. When working on the [Data Center Terraform](https://github.com/atlassian-labs/data-center-terraform) project it's recommended that a dev environment is set up with the same tools.

??? info "CLI Tooling"

    A number of CLI tools are recommended for working on this project. See the [Prerequisites guide](../../userguide/PREREQUISITES/) for details.

??? info "Golang"

    [Go language](https://go.dev/){.external} is used extensively for testing this project, as such it needs to be installed. Check if Go is already installed by running the following command:
    
     ```shell
     go version
     ```
    
    If Go is not installed, install it by following the [official instructions](https://golang.org/doc/install).

??? info "Pre-commit hook"

    Configure [pre-commit](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks){.external} hook and [TFLint](https://github.com/terraform-linters/tflint){.external} to maintain quality and consistency of the Terraform scripts.
    
    Install [pre-commit](https://pre-commit.com/).
    
    ```shell
    brew install pre-commit
    ```
        
    In a terminal, change the directory to the repository root and run `pre-commit install`. Now install [TFLint](https://github.com/terraform-linters/tflint).
       
    ```shell
    brew install tflint
    ```
    
    
    Add the following content to `.tflint.hcl`:
    
    ```hcl
    plugin "aws" {
      enabled = true
      version = "0.5.0"
      source  = "github.com/terraform-linters/tflint-ruleset-aws"
    }
    ```
    
    Initialize TFLint:
    
    ```shell
    tflint --init
    ```