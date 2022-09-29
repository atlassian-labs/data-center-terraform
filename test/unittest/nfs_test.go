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
	assert.Contains(t, err.Error(), "\"namespace\" is not set")
	assert.Contains(t, err.Error(), "\"product\" is not set")
}

func TestNfsVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(NfsValidVariable, t, nfsModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "helm_release.nfs")
	helmRelease := plan.ResourcePlannedValuesMap["helm_release.nfs"]
	values := helmRelease.AttributeValues["values"].([]interface{})[0].(string)

	expectedHelmValues := fmt.Sprintf("\"nameOverride\": \"%s\"\n\"persistence\":\n  \"volumeClaimName\": \"%s\"\n\"resources\":\n  \"limits\":\n    \"cpu\": \"%s\"\n    \"memory\": \"%s\"\n  \"requests\":\n    \"cpu\": \"%s\"\n    \"memory\": \"%s\"\n\"service\":\n  \"clusterIP\": \"%s\"\n",
		nfsVarChartNameOverride, nfsPvc, nfsLimitsCpu, nfsLimitsMemory, nfsRequestsCpu, nfsRequestsMemory, nfsServiceIPAddress)

	expectedNamespace := nfsVarNamespace

	assert.Equal(t, productName+"-nfs", helmRelease.AttributeValues["name"])
	assert.Equal(t, expectedNamespace, helmRelease.AttributeValues["namespace"])
	assert.Equal(t, expectedHelmValues, values)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "kubernetes_persistent_volume.nfs_shared_home")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "kubernetes_persistent_volume_claim.nfs_shared_home")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "kubernetes_persistent_volume.product_shared_home_pv")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "kubernetes_persistent_volume_claim.product_shared_home_pvc")
}
