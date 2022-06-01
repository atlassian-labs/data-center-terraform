package e2etest

import (
	"testing"

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
