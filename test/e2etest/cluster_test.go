package e2etest

import (
	"github.com/aws/aws-sdk-go/service/autoscaling"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
)

func clusterHealthTests(t *testing.T, testConfig TestConfig) {
	printTestBanner("Cluster", "Tests")

	config := getKubectlOptions(testConfig)
	nodes := k8s.GetNodes(t, config)

	// kubectl describe deployments cluster-autoscaler-aws-cluster-autoscaler -n kube-system
	output, err := k8s.RunKubectlAndGetOutputE(t, config, "describe", "deployments", "cluster-autoscaler-aws-cluster-autoscaler", "-n", "kube-system")

	assert.NoError(t, err)
	assert.Contains(t, output, "1 available")

	assert.Equal(t, expectedNumberOfNodes, len(nodes), "Expected 2 nodes in the cluster")
}

func checkAGSAndEC2Tags(t *testing.T, testConfig TestConfig) {
	printTestBanner("Check EC2 Instances", "Tags")
	// get all instances with tag Name=$e2e_env_name and ensure there are 2 of them
	ec2Instances := aws.GetEc2InstanceIdsByTag(t, testConfig.AwsRegion, "Name", testConfig.EnvironmentName)
	assert.Equal(t, 2, len(ec2Instances))

	// describe ASGs and filter them by tag Name=$e2e_env_name and ensure there's 1 such ASG
	asgClient := aws.NewAsgClient(t, testConfig.AwsRegion)
	tagName := "tag:Name"
	tagValue := testConfig.EnvironmentName
	input := &autoscaling.DescribeAutoScalingGroupsInput{
		Filters: []*autoscaling.Filter{
			{
				Name: &tagName,
				Values: []*string{
					&tagValue,
				},
			},
		},
	}
	autoScalingGroups, err_ := asgClient.DescribeAutoScalingGroups(input)
	assert.NoError(t, err_)
	assert.Equal(t, 1, len(autoScalingGroups.AutoScalingGroups))

}
