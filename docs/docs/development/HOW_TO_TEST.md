# Testing

## Structure

You can find the tests in the `unittest` and `e2etest` subdirectories under `/test`.

### `unittest`

The `unittest` subdirectory includes module-level `terraform plan` validation tests. It is required to implement the unit tests for each module. Make sure each test case covers default, customised and invalid conditions.

### `e2etest`

The `e2etest` subdirectory contains the end-to-end infrastructure and product tests. The tests cover the entire deployment process, including the provisioning of resources into a cloud provider.

Each product will have one test function that covers all the states. The test function starts with generating configurations for the `terratest`, `helm`, `kubectl` commands. You can modify the configuration variables in the `GenerateConfigForProductE2eTest()` function.

The provisioning process is as follows:

1. Create AWS resources using Terraform.
2. Create an EKS namespace (product name by default).
3. Clone the Atlassian Helm chart repository and install the specified product using Helm.
    
Once the cluster and product are initialized, assert functions will validate Terraform outputs.

!!! warning "The `bamboo_test.go` file will only test resource creation and validation"
    To test the destruction, run `cleanup_test.go`.


## Requirements

The repo uses [Terratest](https://github.com/gruntwork-io/terratest) to run the tests.

Make sure that your testing environment is correctly configured:

### Installing Terraform

1. Check if Terraform is already installed by running the following command:

    ```shell
    terraform version
    ```

2. If Terraform is not installed, install it by following the [official instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### Installing Go

1. Check if Go is already installed by running the following command:

    ```shell
    go version
    ```

2. If Go is not installed, install it by following the [official instructions](https://golang.org/doc/install).

### Installing AWS CLI

We recommend using AWS CLI version 2.

1. Check if AWS CLI version 2 is already installed by running the following command:
    ```shell
    aws --version
    ```
2. If the AWS CLI is not installed or you're running version 1, install AWS CLI version 2 by following the [official instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html){.external}.

### Setting up AWS security credentials

1. Set up a user with an administrator IAM role. See [Configuration basics — AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html){.external}.
2. Set credentials to connect to cloud provider. The project looks for `~/.aws`. For more details refer to [AWS cli-configure-quickstart](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).
    
## Running unit tests

To run unit tests, use the following commands:

```shell
cd test && go get -v -t -d ./... && go mod tidy
go test ./unittest/... -v
```

!!! tip "You can use regex keywords to run specific groups of test cases"
    For example, you can run only VPC module-related tests with `go test./unittest/... -v -run TestVpc`.

## Running end-to-end tests

End-to-end tests take approx. 40–60 min. to complete To run end-to-end tests, use the following commands:

```shell
cd test && mkdir ./e2etest/artifacts
go get -v -t -d ./... && go mod tidy
go test ./e2etest -v -timeout 40m -run Bamboo | tee ./e2etest/artifacts/e2e-test.log
```

To clean up tests, run:

```shell
go test ./e2etest -v -timeout 40m -run Cleanup | tee ./e2etest/artifacts/e2e-test-cleanup.log
```

## Reusing the end-to-end test environment

When you run end-to-end test for the first time, the test function will create an environment configuration file in the `/test/e2etest/artifacts` directory (the default file name is `e2e_test_env_config.json`). You can use this file to reuse the existing Terraform environment directory created by Terratest.

You can use the `-config` flag to specify the configuration file name on the second run and the function will load the configuration and reuse the existing environment. For example:

```shell
go test ./e2etest -v -timeout 40m -run Bamboo -config=e2e_test_env_config.json | tee ./e2etest/artifacts/e2e-test.log
```

You can do the same to clean up tests:

```shell
go test ./e2etest -v -timeout 40m -run Cleanup -config=e2e_test_env_config.json | tee ./e2etest/artifacts/e2e-test-cleanup.log
```

!!! warning "Avoid accidentally overwriting the test environment configuration"
    If the `-config` flag is missing, the second test will create a new test environment and overwrite the `e2e_test_env_config.json` file if it exists. Rename the `e2e_test_env_config.json` file to avoid overwriting it.

## GitHub Actions

Unit and end-to-end tests run in GitHub Actions. You can find the configuration files at `.github/workflows`