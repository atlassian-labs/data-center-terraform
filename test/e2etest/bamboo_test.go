package e2etest

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestBambooModule(t *testing.T) {
	t.Parallel()

	product := "bamboo"
	awsRegion := "ap-northeast-2" // aws.GetRandomStableRegion(t, nil, nil)

	testConfig := GenerateConfig(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.terraformConfig, t)
	// kubectlOptions := GenerateKubectlOptions(testConfig.kubectlConfig)
	helmOptions := GenerateHelmOptions(testConfig.helmConfig)

	// Clean up. NOTE: defer is LIFO stack so the order is important.
	defer terraform.Destroy(t, tfOptions)
	defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	defer helm.Delete(t, helmOptions, testConfig.releaseName, true)

	terraform.InitAndApply(t, tfOptions)

	helm.AddRepo(t, helmOptions, "atlassian-data-center", "https://atlassian.github.io/data-center-helm-charts")

	helm.Install(t, helmOptions, fmt.Sprintf("atlassian-data-center/%s", product), testConfig.releaseName)

}
