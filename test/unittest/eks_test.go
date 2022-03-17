package unittest

import (
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

	assert.Equal(t, "dummy-cluster-name", clusterName)
	assert.Equal(t, "dummy_vpc_id", vpcId)
	assert.Equal(t, []interface{}{"subnet1", "subnet2"}, subnets)
	assert.Equal(t, []interface{}{"instance_type1", "instance_type2"}, instanceTypes)
	assert.Equal(t, "1", minClusterCapacity)
	assert.Equal(t, "10", maxClusterCapacity)
}

func TestEksClusterNameInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(EksWithInvalidClusterName, t, eksModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid EKS cluster name.")
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
	nodeGroupKey := "module.eks.module.node_groups.aws_eks_node_group.workers[\"appNodes\"]"

	terraform.AssertPlannedValuesMapKeyExists(t, plan, nodeGroupKey)
	nodeGroup := plan.ResourcePlannedValuesMap[nodeGroupKey]
	subnets := nodeGroup.AttributeValues["subnet_ids"].([]interface{})

	assert.Equal(t, 1, len(subnets))
}
