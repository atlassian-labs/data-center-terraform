package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVpcNameNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(VpcWithoutName, t, "vpc")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")

}

func TestVpcNameCustomised(t *testing.T) {
	t.Parallel()

	plan := GetVpcDefaultPlans(t)

	vpcName := plan.RawPlan.Variables["vpc_name"].Value
	assert.Equal(t, "test-vpc", vpcName)

}

func TestVpcNameInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(VpcWithInvalidName, t, "vpc")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid vpc name.")
}

// Test VPC CIDR and Subnets
func TestVpcDefaultCidrBlock(t *testing.T) {
	t.Parallel()

	plan := GetVpcDefaultPlans(t)

	vpcCidr := plan.RawPlan.Variables["vpc_cidr"].Value
	assert.Equal(t, "10.0.0.0/18", vpcCidr)
}

func TestVpcCidrBlockInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(VpcWithInvalidCidr, t, "vpc")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid CIDR.")
}

func TestVpcDefaultPublicSubnets(t *testing.T) {
	t.Parallel()

	plan := GetVpcDefaultPlans(t)

	publicSubnet0 := plan.ResourceChangesMap["module.vpc.aws_subnet.public[0]"].Change.After.(map[string]interface{})
	publicSubnet1 := plan.ResourceChangesMap["module.vpc.aws_subnet.public[1]"].Change.After.(map[string]interface{})
	assert.Equal(t, "10.0.16.0/22", publicSubnet0["cidr_block"])
	assert.Equal(t, "10.0.20.0/22", publicSubnet1["cidr_block"])
}

func TestVpcDefaultPrivateSubnets(t *testing.T) {
	t.Parallel()

	plan := GetVpcDefaultPlans(t)

	privateSubnet0 := plan.ResourceChangesMap["module.vpc.aws_subnet.private[0]"].Change.After.(map[string]interface{})
	privateSubnet1 := plan.ResourceChangesMap["module.vpc.aws_subnet.private[1]"].Change.After.(map[string]interface{})
	assert.Equal(t, "10.0.0.0/22", privateSubnet0["cidr_block"])
	assert.Equal(t, "10.0.4.0/22", privateSubnet1["cidr_block"])
}

func TestVpcCidrAndSubnetsCustomised(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(VpcWithCustomisedCidr, t, "vpc")

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	vpcCidr := plan.RawPlan.Variables["vpc_cidr"].Value
	publicSubnet0 := plan.ResourceChangesMap["module.vpc.aws_subnet.public[0]"].Change.After.(map[string]interface{})
	publicSubnet1 := plan.ResourceChangesMap["module.vpc.aws_subnet.public[1]"].Change.After.(map[string]interface{})
	privateSubnet0 := plan.ResourceChangesMap["module.vpc.aws_subnet.private[0]"].Change.After.(map[string]interface{})
	privateSubnet1 := plan.ResourceChangesMap["module.vpc.aws_subnet.private[1]"].Change.After.(map[string]interface{})
	assert.Equal(t, "10.0.0.0/20", vpcCidr)
	assert.Equal(t, "10.0.0.0/24", privateSubnet0["cidr_block"])
	assert.Equal(t, "10.0.1.0/24", privateSubnet1["cidr_block"])
	assert.Equal(t, "10.0.4.0/24", publicSubnet0["cidr_block"])
	assert.Equal(t, "10.0.5.0/24", publicSubnet1["cidr_block"])
}
