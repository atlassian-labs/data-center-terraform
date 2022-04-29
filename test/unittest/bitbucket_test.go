package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const bitbucketModule = "products/bitbucket"

func TestBitbucketVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(BitbucketCorrectVariables, t, bitbucketModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Bitbucket
	bitbucketKey := "helm_release.bitbucket"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, bitbucketKey)
	bitbucket := plan.ResourcePlannedValuesMap[bitbucketKey]
	assert.Equal(t, "deployed", bitbucket.AttributeValues["status"])
	assert.Equal(t, "bitbucket", bitbucket.AttributeValues["chart"])
	assert.Equal(t, float64(testTimeout*60), bitbucket.AttributeValues["timeout"])
	assert.Equal(t, "https://atlassian.github.io/data-center-helm-charts", bitbucket.AttributeValues["repository"])
}

func TestBitbucketVariablesPopulatedWithInvalidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(BitbucketInvalidVariables, t, bitbucketModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid value for variable")
	assert.Contains(t, err.Error(), "Invalid environment name. Valid name is up to 25 characters starting with")
	assert.Contains(t, err.Error(), "Bitbucket configuration is not valid.")
	assert.Contains(t, err.Error(), "Bitbucket administrator configuration is not valid.")
	assert.Contains(t, err.Error(), "Invalid elasticsearch replicas. Valid replicas is a positive integer in")
	assert.Contains(t, err.Error(), "Bitbucket display name must be a non-empty value less than 255 characters.")
	assert.Contains(t, err.Error(), "Installation timeout needs to be a positive number.")
}

func TestBitbucketVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, bitbucketModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"environment_name\" is not set")
	assert.Contains(t, err.Error(), "\"namespace\" is not set")
	assert.Contains(t, err.Error(), "\"vpc\" is not set")
	assert.Contains(t, err.Error(), "\"eks\" is not set")
	assert.Contains(t, err.Error(), "\"installation_timeout\" is not set")
	assert.Contains(t, err.Error(), "\"db_major_engine_version\" is not set")
	assert.Contains(t, err.Error(), "\"db_allocated_storage\" is not set")
	assert.Contains(t, err.Error(), "\"db_instance_class\" is not set")
	assert.Contains(t, err.Error(), "\"db_iops\" is not set")
	assert.Contains(t, err.Error(), "\"bitbucket_configuration\" is not set")
	assert.Contains(t, err.Error(), "\"admin_configuration\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_requests_cpu\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_requests_memory\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_limits_cpu\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_limits_memory\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_storage\" is not set")
	assert.Contains(t, err.Error(), "\"elasticsearch_replicas\" is not set")
	assert.NotContains(t, err.Error(), "display_name")
}

// Variables
var BitbucketCorrectVariables = map[string]interface{}{
	"environment_name": "dummy-environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
		"cluster_size":           2,
		"availability_zone":      "dummy-az",
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "13",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	"db_name":                 "bitbucket",
	"admin_configuration": map[string]interface{}{
		"admin_username":      "dummy_admin_username",
		"admin_password":      "dummy_admin_password",
		"admin_display_name":  "dummy_admin_display_name",
		"admin_email_address": "dummy_admin_email_address",
	},
	"display_name": "dummy_display_name",
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"replica_count":        1,
	"installation_timeout": testTimeout,
	"bitbucket_configuration": map[string]interface{}{
		"helm_version": "1.2.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"license":      "dummy_license",
	},
	"shared_home_size":              "10Gi",
	"nfs_requests_cpu":              "0.25",
	"nfs_requests_memory":           "256Mi",
	"nfs_limits_cpu":                "0.25",
	"nfs_limits_memory":             "256Mi",
	"elasticsearch_requests_cpu":    "1",
	"elasticsearch_requests_memory": "1Gi",
	"elasticsearch_limits_cpu":      "1",
	"elasticsearch_limits_memory":   "1Gi",
	"elasticsearch_storage":         10,
	"elasticsearch_replicas":        2,
}
