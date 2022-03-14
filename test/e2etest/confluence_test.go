package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func confluenceHealthTests(t *testing.T, productUrl string) {
	printTestBanner(confluence, "Tests")

	// Test the status
	assertConfluenceStatus(t, productUrl, "FIRST_RUN")
}

func assertConfluenceStatus(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Confluence Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}
