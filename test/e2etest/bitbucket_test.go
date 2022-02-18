package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func bitbucketHealthTests(t *testing.T, testConfig TestConfig) {
	// Test status endpoint
	assertBitbucketStatusEndpoint(t, testConfig, "RUNNING")

	// Test NFS
	testNFS()
}

func assertBitbucketStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", bitbucket, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("assert Bitbucket StatusEndpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func testNFS() {
	fmt.Println("NFS test coming soon...")
}
