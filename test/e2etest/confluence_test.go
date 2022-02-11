package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig) {

	// Test the PAUSE status
	assertConfluenceStatusEndpoint(t, testConfig, "FIRST_RUN")
}

// TODO: Add MORE integration tests here if needed
func assertConfluenceStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
	println("assert Confluence StatusEndpoint ..... PASSED")
}
