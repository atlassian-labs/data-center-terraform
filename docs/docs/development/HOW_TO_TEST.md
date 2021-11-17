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

## How to run end-to-end test(Approx. 40-45 mins)
1. `cd test && go get -v -t -d ./... && go mod tidy`
2. `go test ./e2etest -v -timeout 40m > e2e-test.log -run Bamboo`
3. Clean up test `go test ./e2etest -v -timeout 40m > e2e-test-cleanup.log -run Cleanup`

## Github Action
Github action will run for unit and end-to-end tests.
Config file is in `.github/workflows`