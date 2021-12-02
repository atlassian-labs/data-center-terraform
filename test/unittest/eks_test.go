package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEksVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, "eks")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"cluster_name\" is not set")
	assert.Contains(t, err.Error(), "\"vpc_id\" is not set")
	assert.Contains(t, err.Error(), "\"subnets\" is not set")
	assert.Contains(t, err.Error(), "\"instance_types\" is not set")
	assert.Contains(t, err.Error(), "\"desired_capacity\" is not set")
}

func TestEksVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, "eks")

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	clusterName := plan.RawPlan.Variables["cluster_name"].Value
	vpcId := plan.RawPlan.Variables["vpc_id"].Value
	subnets := plan.RawPlan.Variables["subnets"].Value
	instanceTypes := plan.RawPlan.Variables["instance_types"].Value
	desiredCapacity := plan.RawPlan.Variables["desired_capacity"].Value

	assert.Equal(t, "dummy-cluster-name", clusterName)
	assert.Equal(t, "dummy_vpc_id", vpcId)
	assert.Equal(t, []interface{}{"subnet1", "subnet2"}, subnets)
	assert.Equal(t, []interface{}{"instance_type1", "instance_type2"}, instanceTypes)
	assert.Equal(t, "1", desiredCapacity)
}

func TestEksClusterNameInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithInvalidClusterName, t, "eks")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid EKS cluster name.")
}

func TestEksDesiredCapacityOverLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithDesiredCapacityOverLimit, t, "eks")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Desired capacity must be between 1 and 10, inclusive.")
}

func TestEksDesiredCapacityUnderLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksDesiredCapacityUnderLimit, t, "eks")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Desired capacity must be between 1 and 10, inclusive.")
}
