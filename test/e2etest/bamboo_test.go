package e2etest

import (
	"fmt"
	"io"
	"net/http"
	"testing"
	"time"

	awsSdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestBambooModule(t *testing.T) {
	t.Parallel()

	product := "bamboo"
	awsRegion := endpoints.ApNortheast2RegionID

	testConfig := GenerateConfigForProductE2eTest(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.TerraformConfig, t)
	kubectlOptions := GenerateKubectlOptions(testConfig.KubectlConfig, tfOptions, testConfig.EnvironmentName)
	helmOptions := GenerateHelmOptions(testConfig.HelmConfig, kubectlOptions)

	defer terraform.Destroy(t, tfOptions)

	terraform.InitAndApply(t, tfOptions)

	defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	defer helm.Delete(t, helmOptions, testConfig.ReleaseName, true)

	assertVPC(t, tfOptions, awsRegion)
	assertEKS(t, tfOptions, awsRegion)
	assertBambooPod(t, kubectlOptions, testConfig.ReleaseName)
	assertIngressAccess(t, testConfig)
}

func assertVPC(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcId, awsRegion)
	assert.Equal(t, "atlassian-dc-e2e-test-vpc", vpc.Name)
	assert.Len(t, vpc.Subnets, 4)
}

func assertEKS(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	session := GenerateAwsSession(awsRegion)
	eksClient := eks.New(session)
	describeClusterInput := &eks.DescribeClusterInput{
		Name: awsSdk.String("atlassian-dc-e2e-test-cluster"),
	}

	eksInfo, err := eksClient.DescribeCluster(describeClusterInput)
	require.NoError(t, err)

	assert.Equal(t, vpcId, *((*eksInfo).Cluster.ResourcesVpcConfig.VpcId))

}

func assertBambooPod(t *testing.T, kubectlOptions *k8s.KubectlOptions, releaseName string) {
	podName := fmt.Sprintf("%s-0", releaseName)
	pod := k8s.GetPod(t, kubectlOptions, podName)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, 5, 30*time.Second)
	assert.Equal(t, pod.Status.ContainerStatuses[0].Ready, true)
}

func assertIngressAccess(t *testing.T, config TestConfig) {
	path := "/setup/setupLicense.action"
	expectedContent := "Welcome to Bamboo Data Center"
	url := fmt.Sprintf("https://%s.%s.%s/%s", config.Product, config.EnvironmentName, config.TerraformConfig.Variables["domain"], path)

	get, err := http.Get(url)
	if err != nil {
		t.Errorf("Error accessing %s: %s", url, err)
	}
	defer get.Body.Close()

	assert.Equal(t, 200, get.StatusCode)
	content, err := io.ReadAll(get.Body)
	if err != nil {
		t.Errorf("Error reading response body: %s", err)
	}
	assert.Contains(t, expectedContent, string(content))
}
