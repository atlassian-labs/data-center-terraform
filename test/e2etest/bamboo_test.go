package e2etest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBambooModule(t *testing.T) {
	t.Parallel()

	product := "bamboo"
	awsRegion := "ap-northeast-2" // aws.GetRandomStableRegion(t, nil, nil)

	testConfig := GenerateConfig(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.terraformConfig, t)
	// kubectlOptions := GenerateKubectlOptions(testConfig.kubectlConfig)
	// helmOptions := GenerateHelmOptions(testConfig.helmConfig)

	// Clean up. NOTE: defer is LIFO stack so the order is important.
	defer terraform.Destroy(t, tfOptions)
	// defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	// defer helm.Delete(t, helmOptions, testConfig.releaseName, true)

	terraform.InitAndApply(t, tfOptions)

	// helm.AddRepo(t, helmOptions, "atlassian-data-center", "https://atlassian.github.io/data-center-helm-charts")

	// helm.Install(t, helmOptions, fmt.Sprintf("atlassian-data-center/%s", product), testConfig.releaseName)
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	privateSubnetsCidrBlocks := terraform.Output(t, tfOptions, "private_subnets_cidr_blocks")
	publicSubnetsCidrBlocks := terraform.Output(t, tfOptions, "public_subnets_cidr_blocks")
	vpc := aws.GetVpcById(t, vpcId, awsRegion)

	assert.Equal(t, vpc.Name, "atlassian-dc-e2e-test-bamboo-vpc")
	assert.Equal(t, vpc.Tags["product"], "bamboo")
	assert.Equal(t, privateSubnetsCidrBlocks, string("[10.0.0.0/24 10.0.1.0/24]"))
	assert.Equal(t, publicSubnetsCidrBlocks, string("[10.0.8.0/24 10.0.9.0/24]"))
	assert.Len(t, vpc.Subnets, 4)

}
