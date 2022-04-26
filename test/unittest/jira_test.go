package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestJiraVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(JiraCorrectVariables, t, "products/jira")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Jira
	jiraKey := "helm_release.jira"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, jiraKey)
	jira := plan.ResourcePlannedValuesMap[jiraKey]
	assert.Equal(t, "deployed", jira.AttributeValues["status"])
	assert.Equal(t, "jira", jira.AttributeValues["chart"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", jira.AttributeValues["repository"])
}

func TestJiraVariablesPopulatedWithInvalidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(JiraInvalidVariables, t, "products/jira")
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid value for variable")
	assert.Contains(t, err.Error(), "Invalid environment name. Valid name is up to 25 characters starting with")
	assert.Contains(t, err.Error(), "Jira configuration is not valid.")
}
