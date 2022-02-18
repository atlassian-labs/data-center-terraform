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
	if assert.Contains(t, string(content), expectedStatus) {
		println("Asserting Bitbucket Status Endpoint ... OK")
	} else {
		println("Asserting Bitbucket Status Endpoint ... FAIL")
	}
}

func testNFS() {
	fmt.Println("NFS test coming soon...")
}
