package e2etest

import (
	"fmt"
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
	vpc := aws.GetVpcById(t, vpcId, awsRegion)

	fmt.Println(vpc, "this is vpc")
	assert.Equal(t, vpc.Name, "atlassian-dc-e2e-test-bamboo-vpc")
	assert.Equal(t, vpc.Tags["product"], "bamboo")
	assert.Len(t, vpc.Subnets, 4)
}
