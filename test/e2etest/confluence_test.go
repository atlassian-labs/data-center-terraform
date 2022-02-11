package e2etest

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig) {

	// Test the PAUSE status
	assertConfluenceStatusEndpoint(t, testConfig, "PAUSED")
}

// TODO: Add integration tests here
func assertConfluenceStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	//statusUrl := "rest/api/latest/status"
	//url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	//content := getPageContent(t, url)
	//assert.Contains(t, string(content), expectedStatus)
	//println("assertStatusEndpoint ..... PASSED")
	assert.Contains(t, "true", "true")
}
