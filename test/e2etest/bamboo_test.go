package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
	"time"
)

func bambooHealthTests(t *testing.T, testConfig TestConfig) {
	// Test the PAUSE status
	pauseBambooServer(t, testConfig)
	assertBambooStatusEndpoint(t, testConfig, "PAUSED")

	// Test the RUNNING status
	resumeBambooServer(t, testConfig)
	assertBambooStatusEndpoint(t, testConfig, "RUNNING")

	// Test Restored Dataset
	assertPlanListEndpoint(t, testConfig)
	assertBambooProjects(t, testConfig)

	// Test online remote agents
	assertRemoteAgentList(t, testConfig)
}

func assertBambooStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
	println("assertBambooStatusEndpoint ..... PASSED")
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig) {
	planUrl := "rest/api/latest/plan"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, planUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "TestPlan")
	println("assertBambooPlanListEndpoint ... PASSED")
}

func assertBambooProjects(t *testing.T, testConfig TestConfig) {
	projUrl := "allProjects.action"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, projUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "<title>All projects - Atlassian Bamboo</title>")
	assert.Contains(t, string(content), "totalRecords: 1")
	println("assertBambooProjects ..... PASSED")
}

func assertRemoteAgentList(t *testing.T, testConfig TestConfig) {
	agentUrl := "admin/agent/configureAgents!doDefault.action"
	// Wait 15 seconds to allow remote agents get online
	time.Sleep(15 * 1000 * time.Millisecond)
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, agentUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "There are currently 3 remote agents online")
	println("assertBambooRemoteAgentList .... PASSED")
}

func resumeBambooServer(t *testing.T, testConfig TestConfig) {
	resumeUrl := "rest/api/latest/server/resume"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, resumeUrl)

	sendPostRequest(t, url, "application/json", nil)
}

func pauseBambooServer(t *testing.T, testConfig TestConfig) {
	pauseUrl := "rest/api/latest/server/pause"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, pauseUrl)

	sendPostRequest(t, url, "application/json", nil)
}
