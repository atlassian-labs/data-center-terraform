# Testing

You can find the tests in the `./unittest` and `./e2etest` subdirectories under `/test`.

### Unit tests

The `unittest` subdirectory includes module-level `terraform plan` validation tests. It is required to implement the unit tests for each module. Make sure each test case covers default, customised and invalid conditions.

### End-to-end tests

The `e2etest` subdirectory contains the end-to-end infrastructure and product tests. The tests cover the entire deployment process, including the provisioning of resources into a cloud provider.

Each product will have one test function that covers all the states. The test function starts with generating configurations for a test environment. You can modify the configuration variables in the `createConfig()` function.

The provisioning process is as follows:

1. Create AWS resources using Terraform.
2. Create an EKS namespace (product name by default).
3. Clone the Atlassian Helm chart repository and install the specified product using Helm.
    
Once the cluster and product are initialized, `bambooHealthTests()` function will validate the installation result.
## Requirements

See the [How to start development guide](HOW_TO_START.md) for details on how your environment should be setup prior to running tests. The repository also uses [Terratest](https://github.com/gruntwork-io/terratest) to run the tests.

### Setting up AWS security credentials

1. Set up a user with an administrator IAM role. See [Configuration basics — AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html){.external}.
2. Set credentials to connect to cloud provider. The project looks for `~/.aws`. For more details refer to [AWS cli-configure-quickstart](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).
    
??? info "Running unit tests"

    To run unit tests, use the following commands:
    
    ```shell
    go get -v -t -d ./... && go mod tidy
    go test ./test/unittest/... -v
    ```
    
    You can use `regex` keywords to run specific groups of test cases. For example, you can run only `VPC` module-related tests with `go test ./unittest/... -v -run TestVpc`.

??? info "Running end-to-end tests"

    End-to-end tests take approx. 40–60 min. to complete. To run end-to-end tests, use the following commands:
    
    ```shell
    export TF_VAR_bamboo_license='<bamboo-license>'
    mkdir -p ./test/e2etest/artifacts
    go get -v -t -d ./... && go mod tidy
    go test ./test/e2etest -v -timeout 60m -run Installer | tee ./test/e2etest/artifacts/e2etest.log
    ```
## GitHub Actions

These unit and end-to-end tests run as part of the [GitHub Actions setup for this repo](https://github.com/atlassian-labs/data-center-terraform/actions){.external}. You can find the configuration file for these actions in `.github/workflows` within the root level of the project.