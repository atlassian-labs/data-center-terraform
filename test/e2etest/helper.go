package e2etest

import (
	"fmt"
	"log"
	"strings"
	"testing"

	awsSdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
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

func GenerateKubectlOptions(config KubectlConfig, tfOptions *terraform.Options, environmentName string) *k8s.KubectlOptions {
	return k8s.NewKubectlOptions(config.ContextName, fmt.Sprintf("%s/kubeconfig_atlassian-dc-%s-cluster", tfOptions.TerraformDir, environmentName), config.Namespace)
}

func GenerateConfigForProductE2eTest(product string, awsRegion string) TestConfig {
	testResourceOwner := "terraform_e2e_test"
	testId := strings.ToLower(random.UniqueId())
	environmentName := "e2eTest" + testId
	releaseName := fmt.Sprintf("%s-%s-%s", product, environmentName, testId)
	domain := "deplops.com"
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
		SetValues: map[string]string{
			"ingress.create": "true", "ingress.host": "bamboo." + environmentName + "." + domain,
			"volumes.sharedHome.customVolume.persistentVolumeClaim.claimName": fmt.Sprintf("atlassian-dc-%s-share-home-pvc", product),
		},
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
	return session.Must(session.NewSession(&awsSdk.Config{
		Region: awsSdk.String(awsRegion),
	}))
}

func K8sDriver(t *testing.T, tfOptions *terraform.Options, environmentName string) *kubernetes.Clientset {
	config, err := clientcmd.BuildConfigFromFlags("", fmt.Sprintf("%s/kubeconfig_atlassian-dc-%s-cluster", tfOptions.TerraformDir, environmentName))
	if err != nil {
		require.NoError(t, err)
	}
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		require.NoError(t, err)
	}
	return clientset
}

func SafeExtractShareHomeVolume(volumes []v1.Volume) v1.Volume {
	if volumes[1].Name == "shared-home" {
		return volumes[1]
	}
	return volumes[0]
}

func GetAvailableRegion(t *testing.T) string {
	for {
		awsRegion := aws.GetRandomRegion(t, nil, []string{
			endpoints.UsEast1RegionID,
			endpoints.UsEast2RegionID,
			endpoints.UsWest1RegionID,
			endpoints.UsWest2RegionID,
			endpoints.AfSouth1RegionID,
			endpoints.ApEast1RegionID,
			endpoints.ApNortheast2RegionID,
			endpoints.ApSoutheast2RegionID,
		}) // Avoid busy/unavailable regions
		vpcs, err := aws.GetVpcsE(t, nil, awsRegion)
		if err != nil {
			require.NoError(t, err)
		}
		if len(vpcs) < 4 {
			return awsRegion
		}
		log.Println(awsRegion, " has reached resource limit, Finding new region")
	}
}
