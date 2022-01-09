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
	license       = "AAABpQ0ODAoPeNqNkkuPmzAQgO/+FUi9tAc22Ks8GgmpWaBaJEjSgJIechnYCbEChhhDl/76Eh77qLpSb56xNf7mm/kUVqjZGGuMaowtjemSzjQrCDVmMEou2OxRljwXJp0ZxtxY3N9TEkEW5fmdx2MUJTpPXN0eOOvQ2W13buAQKxcKYrWGDE2RnOE3pDxCfklBfgOVQllyEHdxno2l1lUWodycHrrQy2NIVwkKVZr6y3c2KLDaHEpTyQrJtpLxGUps82jeaHXKdMbIiPVccNmMl0w3qN42NJA5PvD0/9Da17zG/st/0u4wyxUOuNQwDJL2BI9Qnk3f+mV9f7heJvVPZFfmJjXdxrwowseZv1dOvTr/KDKu/MN1MvHSA2+ckz392hz2TwsRJUfzaJKgispY8qKz/DHHNgXx1tfgIWwK7AZhbXzf2VnuyiNt961HASL+QNNQIlAgb75PkJY4inVt03PtwFnrHp0vFvP5lJI2Mt9nNjIBwUvooF/EEktil/p7aIOycdkYsfG1574/7fNtA7R+Bb4cl5pTQ1p11cjrsRf0B+Xc9r8wLQIUUb4wT0tppQ8pz5X9sFHg6Wu8ebwCFQCNX4pcExadZwH/e1nVGkrb3Giv5A==X02kc"
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

	// Test the number of online remote agents
	assertRemoteAgentList2(t, testConfig)

	// Uninstall and cleanup the environment
	runUninstallScript(testConfig.ConfigPath)
}

func assertStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "rest/api/latest/status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, testConfig.EnvironmentName, domain, statusUrl)
	content := fmt.Sprintf("%s", GetPageContent(t, url))
	assert.Contains(t,content, expectedStatus)
}

func assertPlanListEndpoint(t *testing.T, testConfig TestConfig) {
	planUrl := "rest/api/latest/plan"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, planUrl)
	content := fmt.Sprintf("%s", GetPageContent(t, url))
	assert.Contains(t,content, "TestPlan")
}

func assertRemoteAgentList2(t *testing.T, testConfig TestConfig) {
	agentUrl := "admin/agent/configureAgents!doDefault.action"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, agentUrl)
	content := fmt.Sprintf("%s", GetPageContent(t, url))
	assert.Contains(t,content, "There are currently 3 remote agents online.")
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

	PostPageContent(t, url, "application/json", nil)
}

func pauseServer(t *testing.T, testConfig TestConfig) {
	pauseUrl := "rest/api/latest/server/pause"
	url := fmt.Sprintf("https://%s@%s.%s.%s/%s", credential, product, testConfig.EnvironmentName, domain, pauseUrl)

	PostPageContent(t, url, "application/json", nil)
}

func TestTemp(t *testing.T) {
	//resumeUrl := "rest/api/latest/server/resume"
	//url := fmt.Sprintf("https://%s@bamboo.e2etest-hdr9gv.deplops.com/%s", credential, resumeUrl)
	//resp, err := http.Post(url, "application/json", nil)
	//require.NoError(t, err, "Error accessing url: %s", url)
	//defer resp.Body.Close()
	//assert.NoError(t, err, "Error reading response body")
	//
	//planUrl := "rest/api/latest/plan"
	//url = fmt.Sprintf("https://%s@bamboo.e2etest-hdr9gv.deplops.com/%s", credential, planUrl)
	//content := fmt.Sprintf("%s", GetPageContent(t, url))
	//assert.Contains(t,content, "TestPlan")
	//
	//
	//agentUrl := "admin/agent/configureAgents!doDefault.action"
	//url = fmt.Sprintf("https://%s@bamboo.e2etest-hdr9gv.deplops.com/%s", credential, agentUrl)
	//content = fmt.Sprintf("%s", GetPageContent(t, url))
	//assert.Contains(t,content, "There are currently 3 remote agents online.")

}
