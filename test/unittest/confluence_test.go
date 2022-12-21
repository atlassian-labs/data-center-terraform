package unittest

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

const confluenceModule = "products/confluence"

func TestConfluenceVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(ConfluenceCorrectVariables, t, confluenceModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	confluenceKey := "helm_release.confluence"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, confluenceKey)
	confluence := plan.ResourcePlannedValuesMap[confluenceKey]
	assert.Equal(t, "deployed", confluence.AttributeValues["status"])
	assert.Equal(t, "confluence", confluence.AttributeValues["chart"])
	assert.Equal(t, float64(testTimeout*60), confluence.AttributeValues["timeout"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", confluence.AttributeValues["repository"])

	dbModuleKey := "module.database.module.db.module.db_instance.aws_db_instance.this[0]"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, dbModuleKey)
	dbModule := plan.ResourcePlannedValuesMap[dbModuleKey]
	assert.Equal(t, "dummyUsername", dbModule.AttributeValues["username"])
	assert.Equal(t, "dummyPassword!", dbModule.AttributeValues["password"])
}

func TestConfluenceVariablesPopulatedWithInvalidValues(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(ConfluenceInvalidVariables, t, confluenceModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid value for variable")
	assert.Contains(t, err.Error(), "Invalid environment name. Valid name is up to 25 characters starting with")
	assert.Contains(t, err.Error(), "Confluence database configuration is not valid.")
	assert.Contains(t, err.Error(), "Confluence configuration is not valid.")
	assert.Contains(t, err.Error(), "Invalid build number.")
	assert.Contains(t, err.Error(), "Installation timeout needs to be a positive number.")
}

func TestConfluenceVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, confluenceModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"environment_name\" is not set")
	assert.Contains(t, err.Error(), "\"namespace\" is not set")
	assert.Contains(t, err.Error(), "\"vpc\" is not set")
	assert.Contains(t, err.Error(), "\"eks\" is not set")
	assert.Contains(t, err.Error(), "\"db_configuration\" is not set")
	assert.Contains(t, err.Error(), "\"replica_count\" is not set")
	assert.Contains(t, err.Error(), "\"confluence_configuration\" is not set")
	assert.Contains(t, err.Error(), "\"synchrony_configuration\" is not set")
	assert.Contains(t, err.Error(), "\"enable_synchrony\" is not set")
	assert.Contains(t, err.Error(), "\"installation_timeout\" is not set")
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
		"availability_zone":      "dummy-az",
	},
	"vpc": VpcDefaultModuleVariable,
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
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
		"db_name":              "confluence",
	},
	"replica_count":        1,
	"installation_timeout": testTimeout,
	"confluence_configuration": map[string]interface{}{
		"helm_version": "1.1.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"license":      "dummy_license",
	},
	"synchrony_configuration": map[string]interface{}{
		"cpu":        "1",
		"mem":        "1Gi",
		"min_heap":   "512m",
		"max_heap":   "1024m",
		"stack_size": "1024k",
	},
	"enable_synchrony":         false,
	"db_master_username":       "dummyUsername",
	"db_master_password":       "dummyPassword!",
	"db_snapshot_build_number": "1234",
	"termination_grace_period": 0,
}
