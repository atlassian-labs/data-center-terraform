package e2etest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"os/exec"
	"strconv"
	"testing"
)

func TestInstaller(t *testing.T) {

	productList := []string{jira, confluence, bamboo, bitbucket}
	useDomain, _ := strconv.ParseBool(os.Getenv("USE_DOMAIN"))
	testConfig := createConfig(t, productList, useDomain)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	clusterHealthTests(t, testConfig)

	productUrls := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")

	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig, productUrls[bamboo])
		exportLogFile(bamboo, "logs", "atlassian-bamboo.log")
	}

	if contains(productList, jira) {
		jiraHealthTests(t, productUrls[jira])
		exportLogFile(jira, "log", "atlassian-jira.log")
	}

	if contains(productList, confluence) {
		confluenceHealthTests(t, productUrls[confluence])
		exportLogFile(confluence, "logs", "atlassian-confluence.log")
	}

	if contains(productList, bitbucket) {
		bitbucketHealthTests(t, testConfig, productUrls[bitbucket])
		exportLogFile(bitbucket, "log", "atlassian-bitbucket.log")
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
