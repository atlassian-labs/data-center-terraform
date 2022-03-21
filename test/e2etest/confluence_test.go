package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, productUrl string) {
	printTestBanner(confluence, "Tests")

	// Test Confluence and Synchrony status endpoints
	assertConfluenceStatus(t, productUrl, "FIRST_RUN")
	assertSynchronyStatus(t, productUrl, "OK")
}

func assertConfluenceStatus(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Confluence Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertSynchronyStatus(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "synchrony/heartbeat"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Synchrony Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}
