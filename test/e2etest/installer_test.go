package e2etest

import (
	"os"
	"os/exec"
	"strconv"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestInstaller(t *testing.T) {

	productList := []string{jira, confluence, bamboo, bitbucket}
	useDomain, _ := strconv.ParseBool(os.Getenv("USE_DOMAIN"))
	testConfig := createConfig(t, productList, useDomain)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	// run again with same config. This is to assure that the `re-apply` action finishes without any issue.
	if !useDomain {
		runInstallScript(testConfig.ConfigPath)
	}

	clusterHealthTests(t, testConfig)

	productUrls := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")
	synchronyUrl := terraform.Output(t, &terraform.Options{TerraformDir: "../../"}, "synchrony_url")

	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig, productUrls[bamboo])
	}

	if contains(productList, jira) {
		jiraHealthTests(t, productUrls[jira])
	}

	if contains(productList, confluence) {
		confluenceHealthTests(t, productUrls[confluence], synchronyUrl)
	}

	if contains(productList, bitbucket) {
		bitbucketHealthTests(t, testConfig, productUrls[bitbucket])
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
