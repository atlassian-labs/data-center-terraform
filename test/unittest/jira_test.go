package unittest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
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

// Variables

var JiraCorrectVariables = map[string]interface{}{
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
	"vpc":                     VpcDefaultModuleVariable,
	"pvc_claim_name":          "dummy_pvc_claimname",
	"db_major_engine_version": "12",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"replica_count":           1,
	"jira_configuration": map[string]interface{}{
		"helm_version":        "1.0.0",
		"cpu":                 "2",
		"mem":                 "2Gi",
		"min_heap":            "384m",
		"max_heap":            "786m",
		"reserved_code_cache": "512m",
	},
}
