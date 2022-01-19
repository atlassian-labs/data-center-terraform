package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func bambooHealthTests(t *testing.T, testConfig TestConfig) {
	// Test the PAUSE status
	pauseBambooServer(t, testConfig)
	assertStatusEndpoint(t, testConfig, "PAUSED")

	// Test the RUNNING status
	resumeBambooServer(t, testConfig)
	assertStatusEndpoint(t, testConfig, "RUNNING")

	// Test Restored Dataset
	assertPlanListEndpoint(t, testConfig)
	assertBambooProjects(t, testConfig)

	// Test online remote agents
	assertRemoteAgentList(t, testConfig)
}

func assertStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), expectedStatus)
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig) {
	planUrl := "rest/api/latest/plan"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, planUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "TestPlan")
}

func assertBambooProjects(t *testing.T, testConfig TestConfig) {
	projUrl := "allProjects.action"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, projUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "<title>All projects - Atlassian Bamboo</title>")
	assert.Contains(t, string(content), "totalRecords: 1")
}

func assertRemoteAgentList(t *testing.T, testConfig TestConfig) {
	agentUrl := "admin/agent/configureAgents!doDefault.action"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, agentUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "There are currently 3 remote agents online.")
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
