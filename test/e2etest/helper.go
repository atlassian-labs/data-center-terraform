package e2etest

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

type TestConfig struct {
	terraformConfig TerraformConfig
	helmConfig      HelmConfig
	kubectlConfig   KubectlConfig
	releaseName     string
}

type TerraformConfig struct {
	variables       map[string]interface{}
	envVariables    map[string]string
	targetModuleDir string
}

type HelmConfig struct {
	setValues map[string]string
}

type KubectlConfig struct {
	contextName string
	configPath  string
	namespace   string
}

func GenerateTerraformOptions(config TerraformConfig, t *testing.T) *terraform.Options {
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../../pkg", config.targetModuleDir)

	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         config.variables,
		EnvVars:      config.envVariables,
	})

	return tfOptions
}

func GenerateHelmOptions(config HelmConfig) *helm.Options {
	return &helm.Options{
		SetValues: config.setValues,
	}
}

func GenerateKubectlOptions(config KubectlConfig) *k8s.KubectlOptions {
	return k8s.NewKubectlOptions(config.contextName, config.configPath, config.namespace)
}

func GenerateConfig(product string, awsRegion string) TestConfig {
	testResourceOwner := "terraform_e2e_test"
	releaseName := fmt.Sprintf("%s-e2e-test-%s", product, strings.ToLower(random.UniqueId()))
	terraformConfig := TerraformConfig{
		variables: map[string]interface{}{
			"environment_name": "e2e-test",
			"region_name":      awsRegion,
			"required_tags": map[string]interface{}{
				"resource_owner": testResourceOwner,
			},
		},
		envVariables: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		targetModuleDir: fmt.Sprintf("/products/%s", product),
	}
	helmConfig := HelmConfig{
		setValues: map[string]string{"namespace": product},
	}
	kubectlConfig := KubectlConfig{
		contextName: "",
		configPath:  "",
		namespace:   product,
	}

	return TestConfig{
		releaseName:     releaseName,
		terraformConfig: terraformConfig,
		helmConfig:      helmConfig,
		kubectlConfig:   kubectlConfig,
	}
}
