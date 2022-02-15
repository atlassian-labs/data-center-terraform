package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig) {

	// Test the status
	assertConfluenceStatus(t, testConfig, "FIRST_RUN")

	// Test the Access Mode status
	assertConfluenceAccessmodeStatus(t, testConfig, "READ_WRITE")

	// Test the Current User
	assertConfluenceCurrentUser(t, testConfig, "anonymous")
}

func assertConfluenceStatus(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("asserting Confluence Status...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertConfluenceAccessmodeStatus(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "/rest/api/accessmode"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("asserting Confluence AccessMode Status...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertConfluenceCurrentUser(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "/rest/api/user/current"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("asserting Confluence Current User...")
	assert.Contains(t, string(content), expectedStatus)
}
