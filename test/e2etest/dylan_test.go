package e2etest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func TestDylan(t *testing.T) {

	out := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")["bitbucket"]
	println(out)
}
