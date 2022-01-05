package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestBambooVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, "products/bamboo")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	println(plan.RawPlan.TerraformVersion)

	//efsName := plan.RawPlan.Variables["efs_name"].Value
	//
	//terraform.RequirePlannedValuesMapKeyExists(t, plan, "aws_security_group.this")
	//awsSecurityGroup := plan.ResourcePlannedValuesMap["aws_security_group.this"]
	//
	//assert.Equal(t, "test-efs", efsName)

}
