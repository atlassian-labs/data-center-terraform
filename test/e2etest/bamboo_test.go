package e2etest

import (
	"fmt"
	"testing"
	"time"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBambooModule(t *testing.T) {
	t.Parallel()

	product := "bamboo"
	awsRegion := endpoints.ApNortheast2RegionID // aws.GetRandomStableRegion(t, nil, nil)

	testConfig := GenerateConfig(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.terraformConfig, t)
	kubectlOptions := GenerateKubectlOptions(testConfig.kubectlConfig, tfOptions, testConfig.environmentName)
	helmOptions := GenerateHelmOptions(testConfig.helmConfig, kubectlOptions)

	defer terraform.Destroy(t, tfOptions)

	terraform.InitAndApply(t, tfOptions)

	defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	defer helm.Delete(t, helmOptions, testConfig.releaseName, true)

	k8s.CreateNamespace(t, kubectlOptions, product)
	helm.AddRepo(t, helmOptions, "atlassian-data-center", "https://atlassian.github.io/data-center-helm-charts")
	helm.Install(t, helmOptions, fmt.Sprintf("atlassian-data-center/%s", product), testConfig.releaseName)

	testVPC(t, tfOptions, awsRegion)
	testEKS(t, tfOptions, awsRegion)
	testBamboPod(t, kubectlOptions, testConfig.releaseName)

}

func testVPC(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcId, awsRegion)
	assert.Equal(t, "atlassian-dc-e2e-test-vpc", vpc.Name)
	assert.Len(t, vpc.Subnets, 4)
}

func testEKS(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	session := GenerateAwsSession(awsRegion)
	eksClient := eks.New(session)
	describeClusterInput := &eks.DescribeClusterInput{
		Name: aws_sdk.String("atlassian-dc-e2e-test-cluster"),
	}
	// describeNodeGroupInput := &eks.DescribeNodegroupInput{
	// 	ClusterName:   aws_sdk.String("atlassian-dc-e2e-test-cluster"),
	// 	NodegroupName: aws_sdk.String("appNodes"),
	// }

	eksInfo, err := eksClient.DescribeCluster(describeClusterInput)
	if err != nil {
		AwsErrorHandler(err)
	}
	// nodeGroupInfo, err := eksClient.DescribeNodegroup(describeNodeGroupInput)
	// if err != nil {
	// 	AwsErrorHandler(err)
	// }

	assert.Equal(t, vpcId, *((*eksInfo).Cluster.ResourcesVpcConfig.VpcId))
	// assert.Equal(t, output["node_groups"]["instance_types"], nodeGroupInfo.Nodegroup.InstanceTypes)

}

func testBamboPod(t *testing.T, kubectlOptions *k8s.KubectlOptions, releaseName string) {
	podName := fmt.Sprintf("%s-0", releaseName)
	pod := k8s.GetPod(t, kubectlOptions, podName)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, 5, 30*time.Second)
	assert.Equal(t, pod.Status.ContainerStatuses[0].Ready, true)
}
