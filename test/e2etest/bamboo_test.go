package e2etest

import (
	"encoding/json"
	"fmt"
	"github.com/stretchr/testify/assert"
	"net/http"
	"testing"
	"time"
)

type Agent struct {
	ID      int    `json:"id"`
	Name    string `json:"name"`
	Type    string `json:"type"`
	Active  bool   `json:"active"`
	Enabled bool   `json:"enabled"`
	Busy    bool   `json:"busy"`
}

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
	time.Sleep(20 * time.Second)
	println("Asserting Bamboo Remote Agents...")
	agentUrl := "rest/api/latest/agent"
	url := fmt.Sprintf("%s/%s", productUrl, agentUrl)
	req, err := http.NewRequest("GET", url, nil)
	assert.NoError(t, err)
	username := "admin"
	password := testConfig.BambooPassword
	req.SetBasicAuth(username, password)
	client := &http.Client{}
	resp, err := client.Do(req)
	assert.NoError(t, err)
	defer resp.Body.Close()
	assert.Equal(t, http.StatusOK, resp.StatusCode, "Expected status code 200")
	var agents []Agent
	err = json.NewDecoder(resp.Body).Decode(&agents)
	assert.NoError(t, err)
	expectedNumAgents := 2
	assert.GreaterOrEqual(t, len(agents), expectedNumAgents, "Number of agents should match the expected count")
	activeCount := 0
	for _, agent := range agents {
		if agent.Active {
			activeCount++
		}
	}
	assert.GreaterOrEqual(t, activeCount, 2, "There should be at least 2 active agents")
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
