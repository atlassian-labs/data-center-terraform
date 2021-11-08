# How to test

## Test
You can find tests in `/test`.
* `unittest` includes module level `terraform plan`validation test.
* `e2etest` is infrastructure and product test. It will follow entire deployment process including provisioning resources to a cloud provider.

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