# How to test

## Test
You can find tests in `/test`.
* `unittest` includes module level `terraform plan`validation test. It is required to have unit test for each module. Make sure each test case cover default, customised and invalid condition.
* `e2etest` is infrastructure and product test. It will follow entire deployment process including provisioning resources to a cloud provider. Each product will have one test function that covers all the states. The test function starts with generating configuration for the `terratest`, `helm`, `kubectl`. You can change config variables as you like in `GenerateConfig()`. The provisioning process will be as follows:
    1. create AWS resources using terraform
    2. create EKS namespace (product name by default)
    3. helm add and install product

    Once cluster and product is ready, the test will start testing the output.


## Requirements:
The repo uses [terratest])(https://github.com/gruntwork-io/terratest) for testing. Followings are requried to run the test:
1. install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli). E.g. `brew install hashicorp/tap/terraform`
2. install [go](https://golang.org/doc/install). E.g. `brew install go`
3. Set credentials to connect cloud provider. The project looks for `~/.aws`
    
## How to run unit test
1. `cd test && go get -v -t -d ./... && go mod tidy`
2. `go test ./unittest/... -v`

## How to run ene-to-end test(Approx. 30-45 mins)
1. `cd test && go get -v -t -d ./... && go mod tidy`
2. `go test ./e2etest/... -v -timeout 60m > e2e-test.log`

## Github Action
Github action will run for unit and end-to-end tests.
Config file is in `.github/workflows`