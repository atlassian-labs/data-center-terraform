package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"regexp"
	"strconv"
	"testing"
	"time"
)

func bambooHealthTests(t *testing.T, testConfig TestConfig, productUrl string) {

	printTestBanner(bamboo, "Tests")

	// Test the PAUSE status
	pauseBambooServer(t, testConfig, productUrl)
	assertStatusEndpoint(t, productUrl, "PAUSED")

	// Test the RUNNING status
	resumeBambooServer(t, testConfig, productUrl)
	assertStatusEndpoint(t, productUrl, "RUNNING")

	// Test Restored Dataset
	assertPlanListEndpoint(t, testConfig, productUrl)
	assertBambooProjects(t, productUrl)

	// Test online remote agents
	assertRemoteAgentList(t, testConfig, productUrl)
}

func assertStatusEndpoint(t *testing.T, productUrl string, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("%s/%s", productUrl, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Bamboo Status Endpoint...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig, productUrl string) {
	planUrl := "rest/api/latest/plan"
	url := fmt.Sprintf("%s/%s", productUrl, planUrl)
	content := getPageContentWithBasicAuth(t, url, "admin", testConfig.BambooPassword)
	println("Asserting Bamboo PlanListEndpoint...")
	assert.Contains(t, string(content), "TestPlan")
}

func assertBambooProjects(t *testing.T, productUrl string) {
	projUrl := "allProjects.action"
	url := fmt.Sprintf("%s/%s", productUrl, projUrl)
	content := getPageContent(t, url)
	println("Asserting Bamboo BambooProjects...")
	assert.Contains(t, string(content), "<title>All projects - Atlassian Bamboo</title>")
	assert.Contains(t, string(content), "totalRecords: 1")
}

func assertRemoteAgentList(t *testing.T, testConfig TestConfig, productUrl string) {
	agentUrl := "admin/agent/configureAgents!doDefault.action"
	time.Sleep(20 * time.Second)
	url := fmt.Sprintf("%s/%s", productUrl, agentUrl)
	content := getPageContentWithBasicAuth(t, url, "admin", testConfig.BambooPassword)
	println("Asserting Bamboo RemoteAgentList...")
	r := regexp.MustCompile(`(?s)There are currently\s+(\d+)\s+remote agents online`)
	matches := r.FindStringSubmatch(string(content))
	assert.NotEmpty(t, matches, "Expected to find a match for 'There are currently X remote agents online' but none was found")
	numAgents, err := strconv.Atoi(matches[1])
	assert.NoError(t, err, "Failed to convert the number of agents to an integer")
	assert.GreaterOrEqual(t, numAgents, 3, "The number of remote agents should be greater than 3")
}

func resumeBambooServer(t *testing.T, testConfig TestConfig, productUrl string) {
	resumeUrl := "rest/api/latest/server/resume"
	url := fmt.Sprintf("%s/%s", productUrl, resumeUrl)

	sendPostRequest(t, url, "application/json", "admin", testConfig.BambooPassword, nil)
}

func pauseBambooServer(t *testing.T, testConfig TestConfig, productUrl string) {
	pauseUrl := "rest/api/latest/server/pause"
	url := fmt.Sprintf("%s/%s", productUrl, pauseUrl)

	sendPostRequest(t, url, "application/json", "admin", testConfig.BambooPassword, nil)
}
