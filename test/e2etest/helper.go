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
	Product         string
	TerraformConfig TerraformConfig
	HelmConfig      HelmConfig
	KubectlConfig   KubectlConfig
	ReleaseName     string
	EnvironmentName string
}

type TerraformConfig struct {
	Variables       map[string]interface{}
	EnvVariables    map[string]string
	TargetModuleDir string
}

type HelmConfig struct {
	SetValues      map[string]string
	KubectlOptions *k8s.KubectlOptions
	ExtraArgs      map[string][]string
}

type KubectlConfig struct {
	ContextName string
	Namespace   string
}

func GenerateTerraformOptions(config TerraformConfig, t *testing.T) *terraform.Options {
	exampleFolder := testStructure.CopyTerraformFolderToTemp(t, "../..", config.TargetModuleDir)

	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         config.Variables,
		EnvVars:      config.EnvVariables,
	})

	return tfOptions
}

func GenerateHelmOptions(config HelmConfig, kubectlOptions *k8s.KubectlOptions) *helm.Options {
	return &helm.Options{
		SetValues:      config.SetValues,
		KubectlOptions: kubectlOptions,
		ExtraArgs:      config.ExtraArgs,
	}
}

func GenerateKubectlOptions(config KubectlConfig, tfOptions *terraform.Options, environmentName string) *k8s.KubectlOptions {
	return k8s.NewKubectlOptions(config.ContextName, fmt.Sprintf("%s/kubeconfig_atlassian-dc-%s-cluster", tfOptions.TerraformDir, environmentName), config.Namespace)
}

func GenerateConfigForProductE2eTest(product string, awsRegion string) TestConfig {
	testResourceOwner := "terraform_e2e_test"
	environmentName := "e2eTest" + random.UniqueId()
	domain := "deplops.com"
	releaseName := fmt.Sprintf("%s-e2e-test-%s", product, strings.ToLower(random.UniqueId()))
	terraformConfig := TerraformConfig{
		Variables: map[string]interface{}{
			"environment_name": environmentName,
			"region":           awsRegion,
			"resource_tags": map[string]string{
				"resource_owner": testResourceOwner,
				"Terraform":      "true",
				"business_unit":  "Engineering-Enterprise DC",
				"service_name":   "dc-infrastructure",
				"git_repository": "github.com/atlassian-labs/data-center-terraform",
			},
			"domain": domain,
		},
		EnvVariables: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		TargetModuleDir: ".",
	}
	helmConfig := HelmConfig{
		SetValues: map[string]string{"ingress.create": "true", "ingress.host": "bamboo." + environmentName + "." + domain},
		ExtraArgs: map[string][]string{"install": {"--wait"}},
	}
	kubectlConfig := KubectlConfig{
		ContextName: fmt.Sprintf("eks_atlassian-dc-%s-cluster", environmentName),
		Namespace:   product,
	}

	return TestConfig{
		Product:         product,
		ReleaseName:     releaseName,
		TerraformConfig: terraformConfig,
		HelmConfig:      helmConfig,
		KubectlConfig:   kubectlConfig,
		EnvironmentName: environmentName,
	}
}

func GenerateAwsSession(awsRegion string) *session.Session {
	return session.Must(session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	}))
}
