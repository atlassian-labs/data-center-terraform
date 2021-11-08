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

## Tests

### Prerequisities

The tests are writen in [Go](https://golang.org/) using [terratest](https://terratest.gruntwork.io/).

1. [Install Go language](https://golang.org/doc/install)
2. Authenticate to an AWS account (this is required even for unit tests)
3. Install the required packages
    ```shell
    cd test && go get -v -t -d ./... && go mod tidy
    ```

### Unit testing

To run the unit tests (in the `test` folder):

```shell
go test ./unittest/... -v
```

Successful run should show end with a similar line:
```
ok  	github.com/atlassian-labs/data-center-terraform/unittest    X.Ys`
```

## End to end testing

[] TODO

## Continuous integration

Tests are running in CI via Github Actions. That means that every commit in every branch is tested. The results are available [in the repository](https://github.com/atlassian-labs/data-center-terraform/actions) and the definition for the build is in `.github/workflows/test.yaml`.