package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBitbucketVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(BitbucketCorrectVariables, t, "products/bitbucket")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Bitbucket
	bitbucketKey := "helm_release.bitbucket"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, bitbucketKey)
	bitbucket := plan.ResourcePlannedValuesMap[bitbucketKey]
	assert.Equal(t, "deployed", bitbucket.AttributeValues["status"])
	assert.Equal(t, "bitbucket", bitbucket.AttributeValues["chart"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", bitbucket.AttributeValues["repository"])
}

// Variables
var BitbucketCorrectVariables = map[string]interface{}{
	//"region_name":      "dummy_region_name",
	"environment_name": "dummy-environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
	},
	"vpc": VpcDefaultModuleVariable,
	//"pvc_claim_name":          "dummy_pvc_claimname",
	"db_major_engine_version": "13",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	//"license":                 "dummy_license",
	//"admin_username":          "dummy_admin_username",
	//"admin_password":          "dummy_admin_password",
	//"admin_display_name":      "dummy_admin_display_name",
	//"admin_email_address":     "dummy_admin_email_address",
	//"ingress":                 map[string]interface{}{},
	"bitbucket_configuration": map[string]interface{}{
		"helm_version": "1.2.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
	},
}
