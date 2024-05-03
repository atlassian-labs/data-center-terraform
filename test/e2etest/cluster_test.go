package e2etest

import (
	"encoding/base64"
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/elbv2"
	"strconv"
	"testing"

	aws_sdk "github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
)

func clusterHealthTests(t *testing.T, testConfig TestConfig) {
	printTestBanner("Cluster", "Tests")

	config := getKubectlOptions(t, testConfig)
	nodes := k8s.GetNodes(t, config)

	// kubectl describe deployments cluster-autoscaler-aws-cluster-autoscaler -n kube-system
	output, err := k8s.RunKubectlAndGetOutputE(t, config, "describe", "deployments", "cluster-autoscaler-aws-cluster-autoscaler", "-n", "kube-system")

	assert.NoError(t, err)
	assert.Contains(t, output, "1 available")

	assert.GreaterOrEqual(t, expectedNumberOfNodes, len(nodes), "Expected at least 2 nodes in the cluster")
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
	autoScalingGroups, err := asgClient.DescribeAutoScalingGroups(input)
	assert.NoError(t, err)
	assert.Equal(t, 1, len(autoScalingGroups.AutoScalingGroups))
}

func checkLoadBalancerTags(t *testing.T, testConfig TestConfig) {
	printTestBanner("Check Nginx LoadBalancer", "Tags")
	sess := session.Must(session.NewSession(&aws_sdk.Config{
		Region: aws_sdk.String(testConfig.AwsRegion),
	}))

	ec2Svc := ec2.New(sess)
	describeTagsOutput, err := ec2Svc.DescribeTags(&ec2.DescribeTagsInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws_sdk.String("tag:" + "service_name"),
				Values: []*string{aws_sdk.String(testConfig.EnvironmentName)},
			},
			{
				Name:   aws_sdk.String("resource-type"),
				Values: []*string{aws_sdk.String("load-balancer")},
			},
		},
	})
	assert.NoError(t, err)
	resourceIDs := make([]*string, 0)
	for _, tagDescription := range describeTagsOutput.Tags {
		resourceIDs = append(resourceIDs, tagDescription.ResourceId)
	}
	assert.Greater(t, len(resourceIDs), 0)

	elbClient := elbv2.New(sess)
	describeLBsOutput, err := elbClient.DescribeLoadBalancers(&elbv2.DescribeLoadBalancersInput{
		LoadBalancerArns: resourceIDs,
	})

	for _, lb := range describeLBsOutput.LoadBalancers {
		fmt.Printf("LoadBalancer Name: %s, ARN: %s, Type: %s\n", *lb.LoadBalancerName, *lb.LoadBalancerArn, *lb.Type)
	}
	assert.Greater(t, len(describeLBsOutput.LoadBalancers), 0)
}

func checkLaunchTemplate(t *testing.T, testConfig TestConfig) {
	printTestBanner("Check LaunchTemplate", "UserData")
	var ltId string
	clusterName := fmt.Sprintf("atlas-%s-cluster", testConfig.EnvironmentName)
	ec2Client := aws.NewEc2Client(t, testConfig.AwsRegion)

	describeTagsInput := &ec2.DescribeTagsInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws_sdk.String("key"),
				Values: []*string{aws_sdk.String("eks:cluster-name")},
			},
			{
				Name:   aws_sdk.String("value"),
				Values: []*string{aws_sdk.String(clusterName)},
			},
		},
	}

	tagsOutput, err := ec2Client.DescribeTags(describeTagsInput)
	if err != nil {
		fmt.Printf("Failed to describe tags: %v", err)
	}

	for _, tag := range tagsOutput.Tags {
		if *tag.ResourceType == "launch-template" {
			fmt.Printf("Found Launch Template with ID: %s for tag eks:cluster-name\n", *tag.ResourceId)
			ltId = *tag.ResourceId
		}
	}

	input := &ec2.DescribeLaunchTemplateVersionsInput{
		LaunchTemplateId: aws_sdk.String(ltId),
		Versions:         []*string{aws_sdk.String("$Latest")},
	}

	output, err := ec2Client.DescribeLaunchTemplateVersions(input)
	if err != nil {
		fmt.Printf("Failed to describe launch template versions: %v", err)
	}

	if len(output.LaunchTemplateVersions) == 0 {
		fmt.Printf("No launch template versions found for ID: %s", ltId)
	}

	userDataB64 := output.LaunchTemplateVersions[0].LaunchTemplateData.UserData
	if userDataB64 == nil || *userDataB64 == "" {
		fmt.Printf("User data is empty or not available")
	}
	userData, err := base64.StdEncoding.DecodeString(*userDataB64)
	if err != nil {
		fmt.Printf("Failed to decode user data: %v", err)
	}

	// assert inclusion of crodwstrike and osquery scripts to user data of the launch template
	assert.Contains(t, string(userData[:]), "systemctl start falcon-sensor.service")
	assert.Contains(t, string(userData[:]), "systemctl start osqueryd")
}

func checkEbsVolumes(t *testing.T, testConfig TestConfig) {
	printTestBanner("Check EBS Volume", "Size")
	expectedDefaultVolumeSize := "50"
	ec2Client := aws.NewEc2Client(t, testConfig.AwsRegion)
	tagName := "tag:Name"
	tagValue := testConfig.EnvironmentName
	input := &ec2.DescribeVolumesInput{
		Filters: []*ec2.Filter{
			{
				Name: &tagName,
				Values: []*string{
					&tagValue,
				},
			},
		}}
	result, _ := ec2Client.DescribeVolumes(input)
	assert.Equal(t, expectedDefaultVolumeSize, strconv.FormatInt(*result.Volumes[0].Size, 10))
}
