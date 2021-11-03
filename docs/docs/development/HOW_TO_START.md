# How to start

## Codebase
You can find the repo here: [Data Center Terraform](https://github.com/atlassian-labs/data-center-terraform).
Please clone the repo on your local:

```shell
git clone git@github.com:atlassian-labs/data-center-terraform.git
```

## Requirements:
Make sure you have installed the following tools, if not install them:
1. install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). E.g. `brew install hashicorp/tap/terraform`
2. install [helm](https://helm.sh/docs/intro/install/). E.g. `brew install helm`
3. install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) E.g:
    
```shell
curl "https://awscli.amazonaws.com/AWSCLIV2-2.0.30.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

## Github Pre-commit hook
1. Install [pre-commit](https://pre-commit.com/). E.g. `brew install pre-commit`
2. Run `pre-commit install` in the repo.
3. Install [tflint](https://github.com/terraform-linters/tflint). E.g. `brew install tflint`
4. Add the following content into `.tflint.hcl`:
    ```hcl
    plugin "aws" {
        enabled = true
        version = "0.5.0"
        source  = "github.com/terraform-linters/tflint-ruleset-aws"
    }
    ```
5. run the following command:
    ```shell
    tflint --init
    ```