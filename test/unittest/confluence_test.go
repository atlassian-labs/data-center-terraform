package unittest

import (
	"github.com/stretchr/testify/assert"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestConfluenceVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(ConfluenceCorrectVariables, t, "products/confluence")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Bamboo
	confluenceKey := "helm_release.confluence"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, confluenceKey)
	confluence := plan.ResourcePlannedValuesMap[confluenceKey]
	assert.Equal(t, "deployed", confluence.AttributeValues["status"])
	assert.Equal(t, "confluence", confluence.AttributeValues["chart"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", confluence.AttributeValues["repository"])
}

// Variables

var ConfluenceCorrectVariables = map[string]interface{}{
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
	"vpc":            VpcDefaultModuleVariable,
	"pvc_claim_name": "dummy_pvc_claimname",
	"ingress": map[string]interface{}{
		"ingress": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"db_major_engine_version": "11",
	"db_configuration": map[string]interface{}{
		"db_allocated_storage": 5,
		"db_instance_class":    "dummy_db_instance_class",
		"db_iops":              1000,
	},
	"confluence_configuration": map[string]interface{}{
		"helm_version": "1.1.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"license":      "dummy_license",
	},
	"enable_synchrony": false,
}
