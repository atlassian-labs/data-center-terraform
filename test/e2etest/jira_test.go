package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func jiraHealthTests(t *testing.T, testConfig TestConfig) {
	assertJiraStatusEndpoint(t, testConfig, "PAUSED")
}

func assertJiraStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
	println("assertStatusEndpoint ..... PASSED")
}
