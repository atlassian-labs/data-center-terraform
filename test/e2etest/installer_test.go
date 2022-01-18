package e2etest

import (
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

	// Run bamboo health tests
	bambooHealthTests(t, testConfig)

	// Uninstall and cleanup the environment
	runUninstallScript(testConfig.ConfigPath)
}

func runInstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "install.sh",
		Args:   []string{"install.sh", "-c", configPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
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
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
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

