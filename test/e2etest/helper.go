package e2etest

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

type TestConfig struct {
	terraformConfig TerraformConfig
	helmConfig      HelmConfig
	kubectlConfig   KubectlConfig
	releaseName     string
	environmentName string
}

type TerraformConfig struct {
	variables       map[string]interface{}
	envVariables    map[string]string
	targetModuleDir string
}

type HelmConfig struct {
	setValues      map[string]string
	KubectlOptions *k8s.KubectlOptions
	ExtraArgs      map[string][]string
}

type KubectlConfig struct {
	contextName string
	namespace   string
}

func GenerateTerraformOptions(config TerraformConfig, t *testing.T) *terraform.Options {
	exampleFolder := testStructure.CopyTerraformFolderToTemp(t, "../..", config.targetModuleDir)

	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         config.variables,
		EnvVars:      config.envVariables,
	})

	return tfOptions
}

func GenerateHelmOptions(config HelmConfig, kubectlOptions *k8s.KubectlOptions) *helm.Options {
	return &helm.Options{
		SetValues:      config.setValues,
		KubectlOptions: kubectlOptions,
		ExtraArgs:      config.ExtraArgs,
	}
}

func GenerateKubectlOptions(config KubectlConfig, tfOptions *terraform.Options, environmentName string) *k8s.KubectlOptions {
	return k8s.NewKubectlOptions(config.contextName, fmt.Sprintf("%s/kubeconfig_atlassian-dc-%s-cluster", tfOptions.TerraformDir, environmentName), config.namespace)
}

func GenerateConfigForProductE2eTest(product string, awsRegion string) TestConfig {
	testResourceOwner := "terraform_e2e_test"
	environmentName := "e2e-test"
	releaseName := fmt.Sprintf("%s-e2e-test-%s", product, strings.ToLower(random.UniqueId()))
	terraformConfig := TerraformConfig{
		variables: map[string]interface{}{
			"environment_name": environmentName,
			"region":           awsRegion,
			"resource_tags": map[string]string{
				"resource_owner": testResourceOwner,
				"Terraform":      "true",
				"business_unit":  "Engineering-Enterprise DC",
				"service_name":   "dc-infrastructure",
				"git_repository": "github.com/atlassian-labs/data-center-terraform",
			},
		},
		envVariables: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		targetModuleDir: ".",
	}
	helmConfig := HelmConfig{
		setValues: map[string]string{},
		ExtraArgs: map[string][]string{"install": {"--wait"}},
	}
	kubectlConfig := KubectlConfig{
		contextName: fmt.Sprintf("eks_atlassian-dc-%s-cluster", environmentName),
		namespace:   product,
	}

	return TestConfig{
		releaseName:     releaseName,
		terraformConfig: terraformConfig,
		helmConfig:      helmConfig,
		kubectlConfig:   kubectlConfig,
		environmentName: environmentName,
	}
}

func GenerateAwsSession(awsRegion string) *session.Session {
	return session.Must(session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	}))
}
