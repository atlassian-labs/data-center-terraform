package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIngressIsCreated(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"cluster_name": "dummy-cluster-name",
		"vpc_id":       "dummy_vpc_id",
		"subnets":      []string{"subnet1", "subnet2"},
		"eks_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"instance_types":   []string{"instance_type1", "instance_type2"},
		"desired_capacity": 1,
		"ingress_domain":   "test.deplops.com", // needs to be a real domain otherwise this test will fail
	}, t, "eks")

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	ingressKey := "helm_release.ingress"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, ingressKey)
	ingress := plan.ResourcePlannedValuesMap[ingressKey]

	assert.Equal(t, "test.deplops.com", plan.RawPlan.Variables["ingress_domain"].Value)

	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "https://kubernetes.github.io/ingress-nginx", ingress.AttributeValues["repository"])
}
