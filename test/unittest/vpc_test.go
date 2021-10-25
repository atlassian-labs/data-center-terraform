package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const TestResourceOwner = "terraform_unit_test"

//Test CIDR variable.
func TestVpcDefaultCidrBlock(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
	}, t)

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

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"vpc_cidr": "10.0.0.0/18",
	}, t)

	// Run `terraform init`, `terraform plan`, and `terraform show`
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.this[0]")
	vpc := plan.ResourcePlannedValuesMap["module.vpc.aws_vpc.this[0]"]
	vpcCidr := vpc.AttributeValues["cidr_block"]
	assert.Equal(t, "10.0.0.0/18", vpcCidr)

}

func TestVpcInvalidCidrBlock(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"vpc_cidr": "10.0/16",
	}, t)

	_, error := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, error)
	assert.Contains(t, error.Error(), "Invalid CIDR.")
}

// Test Enable DNS Hostname variable.
func TestVpcDefaultDnsHostnamesVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
	}, t)

	// Run `terraform init`, `terraform plan`, and `terraform show`
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// Get the plan struct and assert values
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.this[0]")
	vpc := plan.ResourcePlannedValuesMap["module.vpc.aws_vpc.this[0]"]
	dnsHostname := vpc.AttributeValues["enable_dns_hostnames"]
	assert.Equal(t, true, dnsHostname)

}

func TestVpcCustomisedDnsHostnamesVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"enable_dns_hostnames": false,
	}, t)

	// Run `terraform init`, `terraform plan`, and `terraform show`
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vpc.aws_vpc.this[0]")
	vpc := plan.ResourcePlannedValuesMap["module.vpc.aws_vpc.this[0]"]
	dnsHostname := vpc.AttributeValues["enable_dns_hostnames"]
	assert.Equal(t, false, dnsHostname)

}

func TestVpcInvalidDnsHostnamesVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"enable_dns_hostnames": "yes",
	}, t)

	_, error := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, error)
}

// Test Single Nat gateway variable.
func TestVpcDefaultSingleNatGatewayVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
	}, t)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	singleNatGateway := plan.RawPlan.Variables["single_nat_gateway"].Value
	assert.Equal(t, true, singleNatGateway)

}

func TestVpcCustomisedSingleNatGatewayVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"single_nat_gateway": false,
	}, t)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	singleNatGateway := plan.RawPlan.Variables["single_nat_gateway"].Value
	assert.Equal(t, false, singleNatGateway)

}

func TestVpcInvalidSingleNatGatewayVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc",
		"required_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"single_nat_gateway": 11330,
	}, t)

	_, error := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, error)
}
