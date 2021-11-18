package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIngressIsCreated(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, "eks")

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	ingressKey := "helm_release.ingress"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, ingressKey)
	ingress := plan.ResourcePlannedValuesMap[ingressKey]

	assert.Equal(t, "test.deplops.com", plan.RawPlan.Variables["ingress_domain"].Value)

	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "https://kubernetes.github.io/ingress-nginx", ingress.AttributeValues["repository"])
}
