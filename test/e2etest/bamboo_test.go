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
	url := fmt.Sprintf("https://%s.%s.%s/%s", bamboo, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("asserting Bamboo Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig) {
	planUrl := "rest/api/latest/plan"
	credential := fmt.Sprintf("admin:%s", testConfig.BambooPassword)
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, bamboo, testConfig.EnvironmentName, domain, planUrl)
	content := getPageContent(t, url)
	println("asserting Bamboo PlanListEndpoint...")
	assert.Contains(t, string(content), "TestPlan")
}

func assertBambooProjects(t *testing.T, testConfig TestConfig) {
	projUrl := "allProjects.action"
	url := fmt.Sprintf("https://%s.%s.%s/%s", bamboo, testConfig.EnvironmentName, domain, projUrl)
	content := getPageContent(t, url)
	println("asserting Bamboo BambooProjects...")
	assert.Contains(t, string(content), "<title>All projects - Atlassian Bamboo</title>")
	assert.Contains(t, string(content), "totalRecords: 1")
}

func assertRemoteAgentList(t *testing.T, testConfig TestConfig) {
	agentUrl := "admin/agent/configureAgents!doDefault.action"
	// Wait 15 seconds to allow remote agents get online
	time.Sleep(20 * time.Second)
	credential := fmt.Sprintf("admin:%s", testConfig.BambooPassword)
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, bamboo, testConfig.EnvironmentName, domain, agentUrl)
	content := getPageContent(t, url)
	println("asserting Bamboo RemoteAgentList...")
	assert.Contains(t, string(content), "There are currently 3 remote agents online")
}

func resumeBambooServer(t *testing.T, testConfig TestConfig) {
	resumeUrl := "rest/api/latest/server/resume"
	credential := fmt.Sprintf("admin:%s", testConfig.BambooPassword)
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, bamboo, testConfig.EnvironmentName, domain, resumeUrl)

	sendPostRequest(t, url, "application/json", nil)
}

func pauseBambooServer(t *testing.T, testConfig TestConfig) {
	pauseUrl := "rest/api/latest/server/pause"
	credential := fmt.Sprintf("admin:%s", testConfig.BambooPassword)
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, bamboo, testConfig.EnvironmentName, domain, pauseUrl)

	sendPostRequest(t, url, "application/json", nil)
}
