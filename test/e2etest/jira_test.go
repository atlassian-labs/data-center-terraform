package e2etest

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	"testing"
)

func jiraHealthTests(t *testing.T, productUrl string, testConfig TestConfig) {
	printTestBanner(jira, "Tests")
	assertJiraStatusEndpoint(t, productUrl, "FIRST_RUN")
	assertAdditionalJvmArgs(t, testConfig)
}

func assertJiraStatusEndpoint(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Jira Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertAdditionalJvmArgs(t *testing.T, testConfig TestConfig) {
	println("Checking Jira JVM ConfigMap ...")
	kubectlOptions := getKubectlOptions(t, testConfig)
	getCmCmd := []string{"get", "cm", "jira-jvm-config", "-n", "atlassian", "-o", "jsonpath='{.data.additional_jvm_args}'"}
	cmData, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, getCmCmd...)
	assert.Nil(t, kubectlError)
	assert.Contains(t, cmData, "-DtestProperty=testValue")
}
