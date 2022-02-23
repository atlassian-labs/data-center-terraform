package e2etest

import (
	"fmt"
	"os"
	"os/exec"
	"testing"
)

func TestInstaller(t *testing.T) {

	// List of the products to test
	productList := []string{jira, confluence, bamboo, bitbucket}
	testConfig := createConfig(t, productList)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	println(fmt.Sprintf("################## AWS REGION '%s' ##################", testConfig.AwsRegion))

	// Install the environment
	runInstallScript(testConfig.ConfigPath)

	// Run Bamboo health tests
	println(fmt.Sprintf("################## Bamboo Tests ##################"))
	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig)
	}

	// Run Jira health tests
	println(fmt.Sprintf("################## Jira Tests ##################"))
	if contains(productList, jira) {
		jiraHealthTests(t, testConfig)
	}

	// Run Confluence health tests
	println(fmt.Sprintf("################## Confluence Tests ##################"))
	if contains(productList, confluence) {
		confluenceHealthTests(t, testConfig)
	}

	// Run Bitbucket health tests
	println(fmt.Sprintf("################## Bitbucket Tests ##################"))
	if contains(productList, bitbucket) {
		bitbucketHealthTests(t, testConfig)
	}
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
