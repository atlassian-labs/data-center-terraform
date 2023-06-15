package e2etest

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig, productUrl string, synchronyUrl string) {
	printTestBanner(confluence, "Tests")

	// Test Confluence and Synchrony status endpoints
	assertConfluenceStatus(t, productUrl, "FIRST_RUN")
	assertSynchronyStatus(t, synchronyUrl, "OK")
	assertS3BucketPermissions(t, testConfig)
}

func assertConfluenceStatus(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Confluence Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertSynchronyStatus(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "heartbeat"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Synchrony Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertS3BucketPermissions(t *testing.T, testConfig TestConfig) {
	println("Asserting S3 permissions ...")
	bucketName := fmt.Sprintf("atlas-%s-cluster-confluence-storage", testConfig.EnvironmentName)
	kubectlOptions := getKubectlOptions(t, testConfig)
	execArgs := []string{"exec", "confluence-0", "-c", "confluence", "--", "/bin/bash", "-c"}

	// install aws cli
	println("Installing AWS CLI ...")
	command := []string{"apt-get update; apt-get install unzip -y; curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\";  unzip awscliv2.zip; ./aws/install"}
	_, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, append(execArgs, command...)...)
	assert.Nil(t, kubectlError)

	// assert write permissions to the bucket
	println("Asserting write permissions ...")
	command = []string{"touch /tmp/test.txt; aws s3api put-object --bucket " + bucketName + " --key conn-test/test.txt --body /tmp/test.txt"}
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, append(execArgs, command...)...)
	assert.Nil(t, kubectlError)

	// assert list permissions to the bucket
	println("Asserting list permissions ...")
	command = []string{"aws s3api list-objects --bucket " + bucketName + " --query 'Contents[].{Key: Key, Size: Size}'"}
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, append(execArgs, command...)...)
	assert.Nil(t, kubectlError)

	// assert get permissions to the bucket
	println("Asserting get permissions ...")
	command = []string{"aws s3api get-object --bucket " + bucketName + " --key conn-test/test.txt /tmp/test.txt"}
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, append(execArgs, command...)...)
	assert.Nil(t, kubectlError)

	// assert delete permissions to the bucket
	println("Asserting delete permissions ...")
	command = []string{"aws s3api delete-object --bucket " + bucketName + " --key conn-test/test.txt"}
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, append(execArgs, command...)...)
	assert.Nil(t, kubectlError)
}
