package e2etest

import (
	"os"
	"os/exec"
	"testing"
)

func TestInstaller(t *testing.T) {

	productList := []string{jira, confluence, bamboo, bitbucket}
	testConfig := createConfig(t, productList)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	clusterHealthTests(t, testConfig)

	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig)
	}

	if contains(productList, jira) {
		jiraHealthTests(t, testConfig)
	}

	if contains(productList, confluence) {
		confluenceHealthTests(t, testConfig)
	}

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
