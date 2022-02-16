package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, testConfig TestConfig) {

	// Test the status
	assertConfluenceStatus(t, testConfig, "FIRST_RUN")
}

func assertConfluenceStatus(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", confluence, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("asserting Confluence Status...")
	assert.Contains(t, string(content), expectedStatus)
}
