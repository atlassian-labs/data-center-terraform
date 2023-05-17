package unittest

import (
	"encoding/base64"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const eksModule = "AWS/eks"

func TestEksVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"cluster_name\" is not set")
	assert.Contains(t, err.Error(), "\"vpc_id\" is not set")
	assert.Contains(t, err.Error(), "\"subnets\" is not set")
	assert.Contains(t, err.Error(), "\"instance_types\" is not set")
	assert.Contains(t, err.Error(), "\"min_cluster_capacity\" is not set")
	assert.Contains(t, err.Error(), "\"max_cluster_capacity\" is not set")
}

func TestEksVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, eksModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	clusterName := plan.RawPlan.Variables["cluster_name"].Value
	vpcId := plan.RawPlan.Variables["vpc_id"].Value
	subnets := plan.RawPlan.Variables["subnets"].Value
	instanceTypes := plan.RawPlan.Variables["instance_types"].Value
	minClusterCapacity := plan.RawPlan.Variables["min_cluster_capacity"].Value
	maxClusterCapacity := plan.RawPlan.Variables["max_cluster_capacity"].Value
	additionalRoles := plan.RawPlan.Variables["additional_roles"].Value
	s3Role := "aws_iam_role.s3_confluence_storage_role[0]"
    s3Policy := "aws_iam_policy.s3_confluence_storage[0]"
    s3PolicyAttachment := "aws_iam_role_policy_attachment.confluence_s3_storage[0]"
    s3Bucket := "aws_s3_bucket.confluence_storage_bucket[0]"
    s3BucketAcl := "aws_s3_bucket_acl.confluence_storage_acl[0]"

	assert.Equal(t, "dummy-cluster-name", clusterName)
	assert.Equal(t, "dummy_vpc_id", vpcId)
	assert.Equal(t, []interface{}{"subnet1", "subnet2"}, subnets)
	assert.Equal(t, []interface{}{"a", "b"}, instanceTypes)
	assert.Equal(t, []interface{}{map[string]interface{}{"rolearn": "dcdarn", "username": "additional_role", "groups": []interface{}{"system:masters"}}}, additionalRoles)
	assert.Equal(t, "1", minClusterCapacity)
	assert.Equal(t, "10", maxClusterCapacity)
	assert.Contains(t, plan.ResourcePlannedValuesMap, s3Role)
    assert.Contains(t, plan.ResourcePlannedValuesMap, s3Policy)
    assert.Contains(t, plan.ResourcePlannedValuesMap, s3PolicyAttachment)
    assert.Contains(t, plan.ResourcePlannedValuesMap, s3Bucket)
    assert.Contains(t, plan.ResourcePlannedValuesMap, s3BucketAcl)
}

func TestEksClusterNameInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithInvalidClusterName, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid EKS cluster name.")
}

func TestEksClusterVersionInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithInvalidClusterVersion, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid EKS K8S version.")
}

func TestEksMinCapacityOverLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithMinCapacityOverLimit, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Minimum cluster capacity must be between 1 and 20, inclusive.")
}

func TestEksMinCapacityUnderLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithMinCapacityUnderLimit, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Minimum cluster capacity must be between 1 and 20, inclusive.")
}

func TestEksMaxCapacityOverLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithMaxCapacityOverLimit, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Maximum cluster capacity must be between 1 and 20, inclusive.")
}

func TestEksMaxCapacityUnderLimit(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithMaxCapacityUnderLimit, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Maximum cluster capacity must be between 1 and 20, inclusive.")
}

func TestAutoscalerHelmRelease(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, eksModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	autoscalerKey := "helm_release.cluster-autoscaler"

	terraform.AssertPlannedValuesMapKeyExists(t, plan, autoscalerKey)
	autoscaler := plan.ResourcePlannedValuesMap[autoscalerKey]

	// verify Bamboo
	assert.Equal(t, "deployed", autoscaler.AttributeValues["status"])
	assert.Equal(t, "cluster-autoscaler", autoscaler.AttributeValues["chart"])
	assert.Equal(t, "https://kubernetes.github.io/autoscaler", autoscaler.AttributeValues["repository"])

	// verify `enable_irsa = true` creates OpenID connector for the cluster
	terraform.AssertPlannedValuesMapKeyExists(t, plan, "module.eks.aws_iam_openid_connect_provider.oidc_provider[0]")

	// verify the IAM policy is created
	terraform.AssertPlannedValuesMapKeyExists(t, plan, "aws_iam_policy.cluster_autoscaler")
}

func TestEksNodeGroupIsOnlyInOneSubnet(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, eksModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	// verify that the EKS node group is only using one subnet
	nodeGroupKey := "module.eks.module.eks_managed_node_group[\"appNodes\"].aws_eks_node_group.this[0]"

	terraform.AssertPlannedValuesMapKeyExists(t, plan, nodeGroupKey)
	nodeGroup := plan.ResourcePlannedValuesMap[nodeGroupKey]
	subnets := nodeGroup.AttributeValues["subnet_ids"].([]interface{})

	assert.Equal(t, 1, len(subnets))
}

func TestEksNodeLaunchTemplate(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithValidValues, t, eksModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	launchTemplateNodeGroupKey := "module.nodegroup_launch_template.aws_launch_template.nodegroup"
	terraform.AssertPlannedValuesMapKeyExists(t, plan, launchTemplateNodeGroupKey)

	nodeGroupLaunchTemplate := plan.ResourcePlannedValuesMap[launchTemplateNodeGroupKey]
	userData, _ := base64.StdEncoding.DecodeString(fmt.Sprint(nodeGroupLaunchTemplate.AttributeValues["user_data"]))
	// assert that modules/AWS/eks/nodegroup_launch_template/templates/userdata.sh.tpl makes it to user_data in launch template
	// and contains aws command to retrieve osquery fleet enrolment secret
	assert.True(t, strings.Contains(string(userData), "aws --region"))
	// assert that aws region for aws cli is set to the current region when osquery_secret_region is undefined
	assert.True(t, strings.Contains(string(userData), "--region us-east-1"))
	// assert that the default osquery version makes it to the userdata in launch template
	assert.True(t, strings.Contains(string(userData), "osquery-5.7.0"))
}

func TestKinesisRegionSelection(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithUnsupportedKinesisRegion, t, eksModule)
	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	launchTemplateNodeGroupKey := "module.nodegroup_launch_template.aws_launch_template.nodegroup"
	terraform.AssertPlannedValuesMapKeyExists(t, plan, launchTemplateNodeGroupKey)

	nodeGroupLaunchTemplate := plan.ResourcePlannedValuesMap[launchTemplateNodeGroupKey]
	userData, _ := base64.StdEncoding.DecodeString(fmt.Sprint(nodeGroupLaunchTemplate.AttributeValues["user_data"]))
	// since eu-west-2 from EksWithUnsupportedKinesisRegion isn't among supported regions, assert fallback to eu-west-1
	assert.True(t, strings.Contains(string(userData), "eu-west-1"))
	// assert that osquery_secret_region makes it to user_data - aws cli command to fetch fleet enrollment secret
	assert.True(t, strings.Contains(string(userData), "--region eu-north-1"))
}
