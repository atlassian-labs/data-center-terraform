package unittest

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var ingressModule = "AWS/ingress"

func TestIngressIsCreatedWithDomain(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc": map[string]interface{}{
			"nat_public_ips": []string{"1.1.1.1", "2.2.2.2"},
		},
		"ingress_domain":              "test.deplops.com",
		"enable_ssh_tcp":              true,
		"load_balancer_access_ranges": []string{"0.0.0.0/0"},
		"enable_https_ingress":        bool(false),
		"resource_tags": map[string]interface{}{
			"environment": "development",
			"project":     "deplops",
			"owner":       "team-a",
		}}, t, ingressModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify the input variable
	assert.Equal(t, "test.deplops.com", plan.RawPlan.Variables["ingress_domain"].Value)

	// verify NAT public IPs are in controller.service.loadBalancerSourceRanges values in helm_release
	expectedCidrs := plan.ResourcePlannedValuesMap["helm_release.ingress"].AttributeValues["set"].([]interface{})
	assert.Contains(t, fmt.Sprintf("%v", expectedCidrs[0]), "0.0.0.0/0,1.1.1.1/32,2.2.2.2/32")

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
		"vpc": map[string]interface{}{
			"nat_public_ips": []string{"1.1.1.1", "2.2.2.2"},
		},
		"load_balancer_access_ranges": []string{"0.0.0.0/0"},
		"enable_https_ingress":        bool(false),
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

func TestIngressVariablesPopulatedWithInvalidValue(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(IngressInvalidVariablesValue, t, ingressModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid CIDR.")
}

func TestIngressVariablesPopulatedWithValidValue(t *testing.T) {
	t.Parallel()
	tfOptions := GenerateTFOptions(IngressValidVariablesValue, t, ingressModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	loadBalancerSourceRanges := plan.RawPlan.Variables["load_balancer_access_ranges"].Value
	enableHttps := plan.RawPlan.Variables["enable_https_ingress"].Value
	// verify the input variable
	assert.Equal(t, []interface{}{"10.12.0.0/16", "10.13.1.1/32"}, loadBalancerSourceRanges)
	assert.Equal(t, "false", enableHttps)

}
