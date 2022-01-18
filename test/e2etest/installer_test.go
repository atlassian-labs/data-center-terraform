package e2etest

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"text/template"
)

const (
	license       = ""
	resourceOwner = "abrokes"
	credential    = "admin:Atlassian21!"  // Admin credential 'username:password'
	product 	  = "bamboo"
	domain  	  = "deplops.com"
)

func TestInstaller(t *testing.T) {

	testConfig := createConfig(t)

	// Install the environment
	runInstallScript(testConfig.ConfigPath)

	// Test the PAUSE status
	pauseServer(t, testConfig)
	assertStatusEndpoint(t, testConfig, "PAUSED")

	// Test the RUNNING status
	resumeServer(t, testConfig)
	assertStatusEndpoint(t, testConfig, "RUNNING")

	// Test the plans
	assertPlanListEndpoint(t, testConfig)

	assertRestoredDataset(t, testConfig)

	// Uninstall and cleanup the environment
	runUninstallScript(testConfig.ConfigPath)
}

func assertStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := fmt.Sprintf("%s", getPageContent(t, url))
	assert.Contains(t,content, expectedStatus)
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig) {
	planUrl := "rest/api/latest/plan"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, planUrl)
	content := fmt.Sprintf("%s", GetPageContent(t, url))
	assert.Contains(t, content, "TestPlan")
}

func assertRestoredDataset(t *testing.T, testConfig TestConfig) {
	projUrl := "allProjects.action"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, projUrl)
	content := GetPageContent(t, url)
	assert.Contains(t, string(content), "<title>All projects - Atlassian Bamboo</title>")
	assert.Contains(t, string(content), "totalRecords: 1")
}

// TODO remove duplication
func runInstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "install.sh",
		Args:   []string{"install.sh", "-c", configPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	cmd.Start()

	// wait `cmd` until it finishes
	cmd.Wait()
}

func runUninstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "uninstall.sh",
		Args:   []string{"uninstall.sh", "-c", configPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	cmd.Start()

	// wait `cmd` until it finishes
	cmd.Wait()
}

type TestConfig struct {
	AwsRegion       string
	License         string
	EnvironmentName string
	ConfigPath      string
	ResourceOwner   string
}

func createConfig(t *testing.T) TestConfig {
	var bambooLicense = license
	if len(bambooLicense) == 0 {
		bambooLicense = os.Getenv("TF_VAR_bamboo_license")
	}
	testConfig := TestConfig{
		AwsRegion:       GetAvailableRegion(t),
		License:         bambooLicense,
		EnvironmentName: EnvironmentName(),
		ResourceOwner:   resourceOwner,
	}

	// variables
	vars := make(map[string]interface{})
	vars["license"] = testConfig.License
	vars["resource_owner"] = resourceOwner
	vars["environment_name"] = testConfig.EnvironmentName
	vars["region"] = testConfig.AwsRegion

	// parse the template
	tmpl, _ := template.ParseFiles("test-config.tfvars.tmpl")

	// create a new file
	file, _ := os.Create("test-config.tfvars")
	defer file.Close()

	// apply the template to the vars map and write the result to file.
	tmpl.Execute(file, vars)

	filePath, _ := filepath.Abs(file.Name())

	testConfig.ConfigPath = filePath
	return testConfig
}

func resumeServer(t *testing.T, testConfig TestConfig) {
	resumeUrl := "rest/api/latest/server/resume"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, resumeUrl)

	sendPostRequest(t, url, "application/json", nil)
}

func pauseServer(t *testing.T, testConfig TestConfig) {
	pauseUrl := "rest/api/latest/server/pause"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, pauseUrl)

	sendPostRequest(t, url, "application/json", nil)
}

