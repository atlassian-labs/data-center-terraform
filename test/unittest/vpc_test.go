package unittest

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const TestResourceOwner = "terraform_unit_test"

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestVpcDefaultCidrBlock(t *testing.T) {
	t.Parallel()

	// Make a copy of the terraform module to a temporary directory. This allows running multiple tests in parallel
	// against the same terraform module.
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../../pkg", "/modules/AWS/vpc")

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	// Given it's unit test, no resources are actually deployed, a random region will make sense.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	planFilePath := filepath.Join(exampleFolder, "plan.out")
	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars: map[string]interface{}{
			"vpc_name": "test_vpc",
			"required_tags": map[string]interface{}{
				"resource_owner": TestResourceOwner,
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		PlanFilePath: planFilePath,
	})

	// Run `terraform init`, `terraform plan`, and `terraform show`
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// Get the plan struct and assert values
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.this[0]")
	vpc := plan.ResourcePlannedValuesMap["module.vpc.aws_vpc.this[0]"]
	vpcCidr := vpc.AttributeValues["cidr_block"]
	assert.Equal(t, "10.0.0.0/16", vpcCidr)

}

func TestVpcCustomisedCidrBlock(t *testing.T) {
	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../../pkg", "/modules/AWS/vpc")
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	planFilePath := filepath.Join(exampleFolder, "plan.out")

	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars: map[string]interface{}{
			"vpc_name": "test_vpc",
			"required_tags": map[string]interface{}{
				"resource_owner": TestResourceOwner,
			},
			"vpc_cidr": "10.0.0.0/18",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		PlanFilePath: planFilePath,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.this[0]")
	vpc := plan.ResourcePlannedValuesMap["module.vpc.aws_vpc.this[0]"]
	vpcCidr := vpc.AttributeValues["cidr_block"]
	assert.Equal(t, "10.0.0.0/18", vpcCidr)

}
