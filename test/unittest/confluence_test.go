package unittest

import (
	"fmt"
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

func TestConfluenceSynchronyInstalled(t *testing.T) {
	t.Parallel()
	t.SkipNow()

	datasetVars := ConfluenceCorrectVariables
	datasetVars["enable_synchrony"] = true
	datasetVars["ingress"] = map[string]interface{}{
		"enabled": true,
	}
	tfOptions := GenerateTFOptions(datasetVars, t, "products/confluence")
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify Dataset import job
	jobKey := "kubernetes_job.import_dataset[0]"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, jobKey)
	job := plan.ResourcePlannedValuesMap[jobKey]
	assert.Equal(t, "kubernetes_job", job.Type)

	spec := job.AttributeValues["spec"].([]interface{})[0]
	template := spec.(map[string]interface{})["template"].([]interface{})[0]
	jobSpec := template.(map[string]interface{})["spec"].([]interface{})[0]
	container := jobSpec.(map[string]interface{})["container"].([]interface{})[0]
	commands := container.(map[string]interface{})["command"].([]interface{})

	// we need to download the dataset
	assert.Contains(t, commands, fmt.Sprintf("apk update && apk add wget && wget %s -O /shared-home/dataset_to_import.zip", DatasetUrl))
}

// Variables

var ConfluenceCorrectVariables = map[string]interface{}{
	"region_name":      "dummy_region_name",
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
	"ingress":                 map[string]interface{}{},
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
