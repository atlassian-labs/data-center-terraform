package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig) {

	// Test the Access Mode status
	assertConfluenceAccessmodeStatus(t, testConfig, "READ_WRITE")

	// Test the Access Mode status
	assertConfluenceCurrentUser(t, testConfig, "anonymous")
}

func assertConfluenceAccessmodeStatus(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "/rest/api/accessmode"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
	println("assert Confluence AccessMode Status ..... PASSED")
}

func assertConfluenceCurrentUser(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "/rest/api/user/current"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
	println("assert Confluence Current User ......... PASSED")
}
