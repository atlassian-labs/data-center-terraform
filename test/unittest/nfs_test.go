package unittest

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const nfsModule = "AWS/nfs"

func TestNfsVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, nfsModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"product\" is not set")
	assert.Contains(t, err.Error(), "\"namespace\" is not set")
}

func TestNfsVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(NfsValidVariable, t, nfsModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "helm_release.nfs")
	helmRelease := plan.ResourcePlannedValuesMap["helm_release.nfs"]
	values := helmRelease.AttributeValues["values"].([]interface{})[0].(string)

	expectedProduct := fmt.Sprintf("%s-nfs", nfsVarProduct)
	expectedHelmValues := fmt.Sprintf("\"nameOverride\": \"%s\"\n", nfsVarChartNameOverride)
	expectedNamespace := nfsVarNamespace

	assert.Equal(t, expectedProduct, helmRelease.AttributeValues["name"])
	assert.Equal(t, expectedNamespace, helmRelease.AttributeValues["namespace"])
	assert.Equal(t, expectedHelmValues, values)

}
