package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBambooVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(BambooCorrectVariables, t, "products/bamboo")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Bamboo
	bambooKey := "helm_release.bamboo"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, bambooKey)
	bamboo := plan.ResourcePlannedValuesMap[bambooKey]
	assert.Equal(t, "deployed", bamboo.AttributeValues["status"])
	assert.Equal(t, "bamboo", bamboo.AttributeValues["chart"])
	assert.Equal(t, float64(testTimeout*60), bamboo.AttributeValues["timeout"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", bamboo.AttributeValues["repository"])

	// verify Bamboo Agents
	bambooAgentKey := "helm_release.bamboo_agent"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, bambooAgentKey)
	bambooAgent := plan.ResourcePlannedValuesMap[bambooAgentKey]
	assert.Equal(t, "deployed", bambooAgent.AttributeValues["status"])
	assert.Equal(t, "bamboo-agent", bambooAgent.AttributeValues["chart"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", bambooAgent.AttributeValues["repository"])
}

func TestBambooVariablesPopulatedWithInvalidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(BambooIncorrectVariables, t, "products/bamboo")
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid value for variable")
	assert.Contains(t, err.Error(), "Invalid environment name. Valid name is up to 25 characters starting with")
	assert.Contains(t, err.Error(), "Bamboo configuration is not valid.")
	assert.Contains(t, err.Error(), "Bamboo database configuration is not valid.")
	assert.Contains(t, err.Error(), "Installation timeout needs to be a positive number.")
	assert.Contains(t, err.Error(), "Invalid email.")
	assert.Contains(t, err.Error(), "Bamboo Agent configuration is not valid.")
	assert.Contains(t, err.Error(), "License is not valid.")
}

// Variables

var BambooCorrectVariables = map[string]interface{}{
	"environment_name": "dummy-environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
		"availability_zone":      "dummy-az",
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "13",
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"dataset_url":          nil,
	"installation_timeout": testTimeout,
	"bamboo_configuration": map[string]interface{}{
		"helm_version": "1.0.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
	},
	"db_configuration": map[string]interface{}{
		"db_allocated_storage": 5,
		"db_instance_class":    "dummy_db_instance_class",
		"db_iops":              1000,
		"db_name":              "bamboo",
	},
	"license":             "dummy_license",
	"admin_username":      "dummy_admin_username",
	"admin_password":      "dummy_admin_password",
	"admin_display_name":  "dummy_admin_display_name",
	"admin_email_address": "dummy_admin@email_address.com",
	"bamboo_agent_configuration": map[string]interface{}{
		"helm_version": "1.0.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"agent_count":  5,
	},
	"termination_grace_period": 0,
}

var BambooIncorrectVariables = map[string]interface{}{
	"environment_name": "1-is-an-invalid-environment-name",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
		"availability_zone":      "dummy-az",
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "13",
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"dataset_url":          nil,
	"installation_timeout": invalidTestTimeout,
	"bamboo_configuration": map[string]interface{}{
		"helm_version": "1.0.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"invalid":      "bamboo-configuration",
	},
	"db_configuration": map[string]interface{}{
		"db_allocated_storage": 5,
		"db_instance_class":    "dummy_db_instance_class",
		"db_iops":              1000,
		"db_name":              "bamboo",
		"invalid":              "value",
	},
	"license":             "",
	"admin_username":      "dummy_admin_username",
	"admin_password":      "dummy_admin_password",
	"admin_display_name":  "dummy_admin_display_name",
	"admin_email_address": "invalid-email",
	"bamboo_agent_configuration": map[string]interface{}{
		"helm_version": "1.0.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"agent_count":  5,
		"invalid":      "value",
	},
}
