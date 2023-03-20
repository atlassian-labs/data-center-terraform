package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCrowdVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(CrowdCorrectVariables, t, "products/crowd")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Crowd
	crowdKey := "helm_release.crowd"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, crowdKey)
	jira := plan.ResourcePlannedValuesMap[crowdKey]
	assert.Equal(t, "deployed", jira.AttributeValues["status"])
	assert.Equal(t, "crowd", jira.AttributeValues["chart"])
	assert.Equal(t, float64(testTimeout*60), jira.AttributeValues["timeout"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", jira.AttributeValues["repository"])
}

func TestCrowdVariablesPopulatedWithInvalidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(CrowdInvalidVariables, t, "products/crowd")
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid value for variable")
	assert.Contains(t, err.Error(), "Invalid environment name. Valid name is up to 25 characters starting with")
	assert.Contains(t, err.Error(), "Crowd configuration is not valid.")
	assert.Contains(t, err.Error(), "Installation timeout needs to be a positive number.")
}
