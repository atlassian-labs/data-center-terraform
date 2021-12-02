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
	assert.Contains(t, err.Error(), "\"efs_name\" is not set")
	assert.Contains(t, err.Error(), "\"region_name\" is not set")
	assert.Contains(t, err.Error(), "\"vpc\" is not set")
	assert.Contains(t, err.Error(), "\"eks\" is not set")
	assert.Contains(t, err.Error(), "\"csi_controller_replica_count\" is not set")
}

func TestEfsVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EfsValidVariable, t, "efs")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	efsName := plan.RawPlan.Variables["efs_name"].Value
	regionName := plan.RawPlan.Variables["region_name"].Value
	eks := plan.RawPlan.Variables["eks"].Value
	vpc := plan.RawPlan.Variables["vpc"].Value
	csiReplicaCount := plan.RawPlan.Variables["csi_controller_replica_count"].Value

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_security_group.this")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_efs_file_system.this")
	awsSecurityGroup := plan.ResourcePlannedValuesMap["aws_security_group.this"]
	awsEfsFileSystem := plan.ResourcePlannedValuesMap["aws_efs_file_system.this"]

	assert.Equal(t, "test-efs", efsName)
	assert.Equal(t, "us-east-1", regionName)
	assert.Equal(t, EksDefaultModuleVariable, eks)
	assert.Equal(t, VpcDefaultModuleVarialbe, vpc)
	assert.Equal(t, "1", csiReplicaCount)
	assert.Equal(t, fmt.Sprintf("%s-security-group", EfsValidVariable["efs_name"]), awsSecurityGroup.AttributeValues["name"])
	assert.Equal(t, VpcDefaultModuleVarialbe["vpc_id"], awsSecurityGroup.AttributeValues["vpc_id"])
	assert.Equal(t, EksDefaultModuleVariable["cluster_name"], awsEfsFileSystem.AttributeValues["creation_token"])

}

func TestEfsVariablesPopulatedWithInvalidRegion(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EfsInvalidVariable, t, "efs")
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "The given key does not identify an element in this collection value.")

}
