package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestIngressIsCreated(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"ingress_domain": "test.deplops.com",
	}, t, "ingress")

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify the input variable
	assert.Equal(t, "test.deplops.com", plan.RawPlan.Variables["ingress_domain"].Value)

	// verify ingress
	ingressKey := "helm_release.ingress"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, ingressKey)
	ingress := plan.ResourcePlannedValuesMap[ingressKey]
	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "ingress-nginx", ingress.AttributeValues["chart"])
	assert.Equal(t, "https://kubernetes.github.io/ingress-nginx", ingress.AttributeValues["repository"])

	// verify certificate
	certificateKey := "module.ingress_certificate.aws_acm_certificate.this[0]"
	certificate := plan.ResourcePlannedValuesMap[certificateKey]
	assert.Equal(t, "*.test.deplops.com", certificate.AttributeValues["domain_name"])
	assert.Contains(t, certificate.AttributeValues["subject_alternative_names"], "test.deplops.com")
	assert.Equal(t, "DNS", certificate.AttributeValues["validation_method"])

	// verify DNS records
	route53Key := "aws_route53_zone.ingress"
	route53 := plan.ResourcePlannedValuesMap[route53Key]
	assert.Equal(t, "test.deplops.com", route53.AttributeValues["name"])
}

func TestIngressRequireDomainVariable(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{}, t, "ingress")

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"ingress_domain\" is not set")
}
