# Testing

## Structure
You can find tests in `/test`.
* `unittest` includes module level `terraform plan`validation test. It is required to implement the unit tests for each module. Make sure each test case covers default, customised and invalid conditions.
* `e2etest` contains the end-to-end tests for infrastructure and products. It will follow the entire deployment process including provisioning resources into a cloud provider. Each product will have one test function that covers all the states. The test function starts with generating configuration for the `terratest`, `helm`, `kubectl` commands. You can change config variables as you like in the `GenerateConfigForProductE2eTest()` function. The provisioning process will be as follows:
    1. Create AWS resources using Terraform
    2. Create EKS namespace (product name by default)
    3. Helm adds Atlassian helm chart repository and install specified product

    Once the cluster and product are initialised, assert functions will validate the terraform outputs.

> :warning: **bamboo_test.go file will only test the resource creation and validation**: You must run cleanup_test.go to test the destruction! 


## Requirements:
The repo uses [Terratest](https://github.com/gruntwork-io/terratest) for testing. The following are required to run the test:
1. install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). E.g. `brew install hashicorp/tap/terraform`
2. install [Go](https://golang.org/doc/install). E.g. `brew install go`
3. Set credentials to connect to cloud provider. The project looks for `~/.aws`. For more details refer to [AWS cli-configure-quickstart](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).
    
## How to run unit test
1. `cd test && go get -v -t -d ./... && go mod tidy`
2. `go test ./unittest/... -v`

You can run test with regex keyword to run specific group of test cases e.g. Running only VPC module related tests `go test./unittest/... -v -run TestVpc`

## How to run end-to-end test(Approx. 40-60 mins)
1. `cd test && mkdir ./e2etest/artifacts`
2. `go get -v -t -d ./... && go mod tidy`
3. `go test ./e2etest -v -timeout 40m -run Bamboo | tee ./e2etest/artifacts/e2e-test.log`
4. Clean up test `go test ./e2etest -v -timeout 40m -run Cleanup | tee ./e2etest/artifacts/e2e-test-cleanup.log`


## How to reuse end-to-end test environment
When you run end-to-end test for the first time, the test function will create an environment config file under `/test/e2etest/artifacts` folder(the default file name is `e2e_test_env_config.json`). This config file allows you to reuse the existing terraform environment directory created by terratest.

You can specify the config file name on the second run and the function will load the config data and reuse the existing environment.
e.g. `go test ./e2etest -v -timeout 40m -run Bamboo -config=e2e_test_env_config.json | tee ./e2etest/artifacts/e2e-test.log`

You can do the same for the clean up test.
e.g. `go test ./e2etest -v -timeout 40m -run Cleanup -config=e2e_test_env_config.json | tee ./e2etest/artifacts/e2e-test-cleanup.log`

!!! Warning "If `-config` flag is not specified, the second test will create a new test environment and overwrite `e2e_test_env_config.json` if existed"
    So make sure you rename `e2e_test_env_config.json` to avoid accidental overwrites.

## Github Action
Github action will run for unit and end-to-end tests.
Config file is in `.github/workflows`