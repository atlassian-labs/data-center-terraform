package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestElasticsearchVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, elasticsearchModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"environment_name\" is not set")
	assert.Contains(t, err.Error(), "\"vpc_subnet_ids\" is not set")
	assert.Contains(t, err.Error(), "\"instance_count\" is not set")
	assert.Contains(t, err.Error(), "\"ebs_volume_size\" is not set")
}

func TestElasticsearchVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(ElasticsearchValidVariable, t, elasticsearchModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	ebsVolumeSize := plan.RawPlan.Variables["ebs_volume_size"].Value
	environmentName := plan.RawPlan.Variables["environment_name"].Value
	instanceCount := plan.RawPlan.Variables["instance_count"].Value
	instanceType := plan.RawPlan.Variables["instance_type"].Value
	volumeType := plan.RawPlan.Variables["volume_type"].Value
	vpcSubnetIds := plan.RawPlan.Variables["vpc_subnet_ids"].Value

	assert.Equal(t, inputVolumeSize, ebsVolumeSize)
	assert.Equal(t, inputEnvironment, environmentName)
	assert.Equal(t, inputInstanceCount, instanceCount)
	assert.Equal(t, inputInstanceType, instanceType)
	assert.Equal(t, inputVolumeType, volumeType)
	assert.EqualValues(t, inputSubnetId, vpcSubnetIds)
}

func TestElasticsearchInstanceTypeInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(ElasticsearchInvalidVariable, t, elasticsearchModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Elasticsearch instance type is invalid.")
}
