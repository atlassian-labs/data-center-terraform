package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVpcNameNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
	}, t, "vpc")

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

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_name": "test-vpc/12",
		"vpc_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
	}, t, "vpc")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid vpc name.")
}
