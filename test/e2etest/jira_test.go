package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func jiraHealthTests(t *testing.T, productUrl string) {
	printTestBanner(jira, "Tests")
	assertJiraStatusEndpoint(t, productUrl, "FIRST_RUN")
}

func assertJiraStatusEndpoint(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Jira Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}
