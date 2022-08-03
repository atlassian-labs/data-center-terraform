package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var ingressModule = "AWS/ingress"

func TestIngressIsCreatedWithDomain(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"ingress_domain":                 "test.deplops.com",
		"enable_ssh_tcp":                 true,
		"TestIngressIsCreatedWithDomain": []string{"0.0.0.0/0"},
	}, t, ingressModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify the input variable
	assert.Equal(t, "test.deplops.com", plan.RawPlan.Variables["ingress_domain"].Value)

	// verify ingress is created
	ingressKey := "helm_release.ingress"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, ingressKey)
	ingress := plan.ResourcePlannedValuesMap[ingressKey]
	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "ingress-nginx", ingress.AttributeValues["chart"])
	assert.Equal(t, "https://kubernetes.github.io/ingress-nginx", ingress.AttributeValues["repository"])

	// verify certificate is created
	certificateKey := "module.ingress_certificate[0].aws_acm_certificate.this[0]"
	certificate := plan.ResourcePlannedValuesMap[certificateKey]
	assert.Equal(t, "*.test.deplops.com", certificate.AttributeValues["domain_name"])
	assert.Contains(t, certificate.AttributeValues["subject_alternative_names"], "test.deplops.com")
	assert.Equal(t, "DNS", certificate.AttributeValues["validation_method"])

	// verify DNS records are created
	route53Key := "aws_route53_zone.ingress[0]"
	route53 := plan.ResourcePlannedValuesMap[route53Key]
	assert.Equal(t, "test.deplops.com", route53.AttributeValues["name"])
}

func TestIngressIsCreatedWithoutDomain(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"TestIngressIsCreatedWithDomain": []string{"0.0.0.0/0"},
	}, t, ingressModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify ingress is created
	ingressKey := "helm_release.ingress"
	terraform.RequirePlannedValuesMapKeyExists(t, plan, ingressKey)
	ingress := plan.ResourcePlannedValuesMap[ingressKey]
	assert.Equal(t, "deployed", ingress.AttributeValues["status"])
	assert.Equal(t, "ingress-nginx", ingress.AttributeValues["chart"])
	assert.Equal(t, "https://kubernetes.github.io/ingress-nginx", ingress.AttributeValues["repository"])

	// verify certificate is not created
	certificateKey := "module.ingress_certificate[0].aws_acm_certificate.this[0]"
	certificate := plan.ResourcePlannedValuesMap[certificateKey]
	assert.Nil(t, certificate)

	// verify DNS records are not created
	route53Key := "aws_route53_zone.ingress[0]"
	route53 := plan.ResourcePlannedValuesMap[route53Key]
	assert.Nil(t, route53)
}

func TestIngressVariablesPopulatedWithInvalidType(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(IngressInvalidVariableType, t, ingressModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid CIDR.")
}

func TestIngressVariablesPopulatedWithInvalidValue(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(IngressInvalidVariablesContent, t, ingressModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid CIDR.")
}

func TestIngressVariablesPopulatedWithValidValue(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(IngressValidVariables, t, ingressModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	loadBalancerSourceRanges := plan.RawPlan.Variables["loadBalancerSourceRanges"].Value

	// verify the input variable
	assert.Equal(t, []interface{}{"10.12.0.0/16", "10.13.1.1/32"}, loadBalancerSourceRanges)

}
