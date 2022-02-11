package e2etest

import (
	"os"
	"os/exec"
	"sort"
	"testing"
)

func TestInstaller(t *testing.T) {

	// List of the products to test
	productList := []string{"bamboo", "jira"}
	testConfig := createConfig(t, productList)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	// Install the environment
	runInstallScript(testConfig.ConfigPath)

	// Run Bamboo health tests
	if contains(productList, "bamboo") {
		bambooHealthTests(t, testConfig)
	}

	// Run Jira health tests
	if contains(productList, "jira") {
		jiraHealthTests(t, testConfig)
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

func contains(s []string, item string) bool {
	i := sort.SearchStrings(s, item)
	return i < len(s) && s[i] == item
}
