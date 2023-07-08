package unittest

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var commonModule = "common"

func TestMonitoringEnabled(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"region_name":          "us-west-2",
		"environment_name":     "staging",
		"eks_version":          "1.21",
		"tags":                 map[string]string{"key1": "value1", "key2": "value2"},
		"instance_types":       []string{"t2.micro", "t3.small"},
		"instance_disk_size":   50,
		"max_cluster_capacity": 10,
		"min_cluster_capacity": 2,
		"domain":               "example.com",
		"namespace":            "namespace",
		"eks_additional_roles": []map[string]interface{}{
			{
				"rolearn":  "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME",
				"username": "ROLE_NAME",
				"groups":   []string{"system:masters"},
			},
		},
		"whitelist_cidr":        []string{"10.0.0.0/16"},
		"enable_https_ingress":  false,
		"enable_ssh_tcp":        false,
		"osquery_secret_name":   "secret",
		"osquery_secret_region": "us-east-1",
		"osquery_env":           "dev",
		"osquery_version":       "5.5.1",
		"kinesis_log_producers_role_arns": map[string]interface{}{
			"eu":     "arn:aws:iam::ACCOUNT_ID:role/KINESIS_LOG_PRODUCER_ROLE_EU",
			"non-eu": "arn:aws:iam::ACCOUNT_ID:role/KINESIS_LOG_PRODUCER_ROLE_NON_EU",
		},
		"osquery_fleet_enrollment_host":     "example.com",
		"monitoring_enabled":                true,
		"monitoring_grafana_expose_lb":      true,
		"prometheus_pvc_disk_size":          "10Gi",
		"grafana_pvc_disk_size":             "10Gi",
		"monitoring_custom_values_file":     "",
		"additional_namespaces":             []string{"namespace1", "namespace2"},
		"confluence_s3_attachments_storage": true,
	}, t, commonModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify NAT public IPs are in controller.service.loadBalancerSourceRanges values in helm_release
	expectedCidrs := plan.ResourcePlannedValuesMap["helm_release.prometheus_monitoring_stack[0]"].AttributeValues["values"].([]interface{})
	assert.Contains(t, fmt.Sprintf("%v", expectedCidrs[1]), "10.0.0.0/16")

	// verify prometheus Helm chart is created
	prometheusKey := "helm_release.prometheus_monitoring_stack[0]"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, prometheusKey)
	ingress := plan.ResourcePlannedValuesMap[prometheusKey]
	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "kube-prometheus-stack", ingress.AttributeValues["chart"])
	assert.Equal(t, "https://prometheus-community.github.io/helm-charts", ingress.AttributeValues["repository"])

}
