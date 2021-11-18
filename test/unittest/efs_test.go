package unittest

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEfsVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, "efs")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"region_name\" is not set")
	assert.Contains(t, err.Error(), "\"efs_tags\" is not set")
	assert.Contains(t, err.Error(), "\"vpc\" is not set")
	assert.Contains(t, err.Error(), "\"eks\" is not set")
	assert.Contains(t, err.Error(), "\"csi_controller_replica_count\" is not set")
}

func TestEfsVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	efsTagsVariable := map[string]interface{}{
		"resource_owner": TestResourceOwner,
	}

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"region_name":                  "us-east-1",
		"eks":                          EksDefaultModuleVariable,
		"vpc":                          VpcDefaultModuleVarialbe,
		"efs_tags":                     efsTagsVariable,
		"csi_controller_replica_count": 1,
	}, t, "efs")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	regionName := plan.RawPlan.Variables["region_name"].Value
	eks := plan.RawPlan.Variables["eks"].Value
	vpc := plan.RawPlan.Variables["vpc"].Value
	efsTags := plan.RawPlan.Variables["efs_tags"].Value
	csiReplicaCount := plan.RawPlan.Variables["csi_controller_replica_count"].Value

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_security_group.this")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_efs_file_system.this")
	awsSecurityGroup := plan.ResourcePlannedValuesMap["aws_security_group.this"]
	awsEfsFileSystem := plan.ResourcePlannedValuesMap["aws_efs_file_system.this"]

	assert.Equal(t, "us-east-1", regionName)
	assert.Equal(t, EksDefaultModuleVariable, eks)
	assert.Equal(t, VpcDefaultModuleVarialbe, vpc)
	assert.Equal(t, efsTagsVariable, efsTags)
	assert.Equal(t, "1", csiReplicaCount)
	assert.Equal(t, fmt.Sprintf("%s-efs-csi", EksDefaultModuleVariable["cluster_name"]), awsSecurityGroup.AttributeValues["name_prefix"])
	assert.Equal(t, VpcDefaultModuleVarialbe["vpc_id"], awsSecurityGroup.AttributeValues["vpc_id"])
	assert.Equal(t, EksDefaultModuleVariable["cluster_name"], awsEfsFileSystem.AttributeValues["creation_token"])

}

func TestEfsVariablesPopulatedWithInvalidRegion(t *testing.T) {
	t.Parallel()

	efsTagsVariable := map[string]interface{}{
		"resource_owner": TestResourceOwner,
	}

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"region_name":                  "invalid-region",
		"eks":                          EksDefaultModuleVariable,
		"vpc":                          VpcDefaultModuleVarialbe,
		"efs_tags":                     efsTagsVariable,
		"csi_controller_replica_count": 1,
	}, t, "efs")
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "The given key does not identify an element in this collection value.")

}
