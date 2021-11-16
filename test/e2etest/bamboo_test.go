package e2etest

import (
	"context"
	"fmt"
	"testing"
	"time"

	awsSdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestBambooModule(t *testing.T) {

	product := "bamboo"
	awsRegion := GetAvailableRegion(t)

	testConfig := GenerateConfigForProductE2eTest(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.terraformConfig, t)
	kubectlOptions := GenerateKubectlOptions(testConfig.kubectlConfig, tfOptions, testConfig.environmentName)
	helmOptions := GenerateHelmOptions(testConfig.helmConfig, kubectlOptions)

	if err := Save("bamboo_tfOptions.json", *tfOptions); err != nil {
		require.NoError(t, err)
	}

	terraform.InitAndApply(t, tfOptions)

	defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	defer helm.Delete(t, helmOptions, testConfig.releaseName, true)

	helm.AddRepo(t, helmOptions, "atlassian-data-center", "https://atlassian.github.io/data-center-helm-charts")
	helm.Install(t, helmOptions, fmt.Sprintf("atlassian-data-center/%s", product), testConfig.releaseName)

	assertVPC(t, tfOptions, awsRegion, testConfig.environmentName)
	assertEKS(t, tfOptions, awsRegion, testConfig.environmentName)
	assertShareHomePV(t, tfOptions, kubectlOptions, testConfig.environmentName, product)
	assertShareHomePVC(t, tfOptions, kubectlOptions, testConfig.environmentName, product)
	assertBambooPod(t, kubectlOptions, testConfig.releaseName, product)

}

func assertVPC(t *testing.T, tfOptions *terraform.Options, awsRegion string, environmentName string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcId, awsRegion)
	assert.Equal(t, fmt.Sprintf("atlassian-dc-%s-vpc", environmentName), vpc.Name)
	assert.Len(t, vpc.Subnets, 4)
}

func assertEKS(t *testing.T, tfOptions *terraform.Options, awsRegion string, environmentName string) {
	vpcId := terraform.Output(t, tfOptions, "vpc_id")
	session := GenerateAwsSession(awsRegion)
	eksClient := eks.New(session)
	describeClusterInput := &eks.DescribeClusterInput{
		Name: awsSdk.String(fmt.Sprintf("atlassian-dc-%s-cluster", environmentName)),
	}

	eksInfo, err := eksClient.DescribeCluster(describeClusterInput)
	require.NoError(t, err)

	assert.Equal(t, vpcId, *((*eksInfo).Cluster.ResourcesVpcConfig.VpcId))

}

func assertShareHomePV(t *testing.T, tfOptions *terraform.Options, kubectlOptions *k8s.KubectlOptions, environmentName string, product string) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	k8sClient := K8sDriver(t, tfOptions, environmentName)
	pvClient := k8sClient.CoreV1().PersistentVolumes()

	_, err := pvClient.Get(ctx, fmt.Sprintf("atlassian-dc-%s-share-home-pv", product), v1.GetOptions{})
	require.NoError(t, err)
}

func assertShareHomePVC(t *testing.T, tfOptions *terraform.Options, kubectlOptions *k8s.KubectlOptions, environmentName string, product string) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	k8sClient := K8sDriver(t, tfOptions, environmentName)
	pvcClient := k8sClient.CoreV1().PersistentVolumeClaims(product)

	_, err := pvcClient.Get(ctx, fmt.Sprintf("atlassian-dc-%s-share-home-pvc", product), v1.GetOptions{})
	require.NoError(t, err)
}

func assertBambooPod(t *testing.T, kubectlOptions *k8s.KubectlOptions, releaseName string, product string) {
	podName := fmt.Sprintf("%s-0", releaseName)
	pod := k8s.GetPod(t, kubectlOptions, podName)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, 5, 30*time.Second)
	shareHomeVolume := SafeExtractShareHomeVolume(pod.Spec.Volumes)

	assert.Equal(t, true, pod.Status.ContainerStatuses[0].Ready)
	assert.Equal(t, fmt.Sprintf("atlassian-dc-%s-share-home-pvc", product), shareHomeVolume.PersistentVolumeClaim.ClaimName)
}
