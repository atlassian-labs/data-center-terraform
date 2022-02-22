package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func jiraHealthTests(t *testing.T, testConfig TestConfig) {
	assertJiraStatusEndpoint(t, testConfig, "FIRST_RUN")
}

func assertJiraStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", jira, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Jira Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}
