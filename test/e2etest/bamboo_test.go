package e2etest

import (
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBambooModule(t *testing.T) {
	t.Parallel()

	product := "bamboo"
	awsRegion := endpoints.ApNortheast2RegionID // aws.GetRandomStableRegion(t, nil, nil)

	testConfig := GenerateConfig(product, awsRegion)
	tfOptions := GenerateTerraformOptions(testConfig.terraformConfig, t)
	// kubectlOptions := GenerateKubectlOptions(testConfig.kubectlConfig)
	// helmOptions := GenerateHelmOptions(testConfig.helmConfig)

	// Clean up. NOTE: defer is LIFO stack so the order is important.
	// defer terraform.Destroy(t, tfOptions)
	// defer helm.RemoveRepo(t, helmOptions, "atlassian-data-center")
	// defer helm.Delete(t, helmOptions, testConfig.releaseName, true)

	// terraform.InitAndApply(t, tfOptions)

	// helm.AddRepo(t, helmOptions, "atlassian-data-center", "https://atlassian.github.io/data-center-helm-charts")

	// helm.Install(t, helmOptions, fmt.Sprintf("atlassian-data-center/%s", product), testConfig.releaseName)

	// testVPC(t, tfOptions, awsRegion)
	testEKS(t, tfOptions, awsRegion)

}

func testVPC(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
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

func testEKS(t *testing.T, tfOptions *terraform.Options, awsRegion string) {
	sess := session.Must(session.NewSession(&aws_sdk.Config{
		Region: aws_sdk.String(awsRegion),
	}))
	svc := eks.New(sess)

	input := &eks.DescribeClusterInput{
		Name: aws_sdk.String("atlassian-dc-e2e-test-bamboo-eks"),
	}
	result, err := svc.DescribeCluster(input)
	if err != nil {
		AwsErrorHandler(err)
	}
	assert.Equal(t, result.Cluster.ResourcesVpcConfig.VpcId, terraform.Output(t, tfOptions, "vpc_id"))
}
