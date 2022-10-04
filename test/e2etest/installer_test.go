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
	defer runUninstallScript(testConfig)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	// run again with same config. This is to assure that the `re-apply` action finishes without any issue.
	runInstallScript(testConfig.ConfigPath)

	clusterHealthTests(t, testConfig)

	productUrls := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")

	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig, productUrls[bamboo])
	}

	if contains(productList, jira) {
		jiraHealthTests(t, productUrls[jira])
	}

	if contains(productList, confluence) {
		confluenceHealthTests(t, productUrls[confluence])
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

func runUninstallScript(config TestConfig) {
	cmd := &exec.Cmd{
		Path:   "uninstall.sh",
		Args:   []string{"uninstall.sh", "-c", config.ConfigPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()

	pythonClean := &exec.Cmd{
		Path:   "clean_env.py",
		Args:   []string{"clean_env.py", "--service_name", config.EnvironmentName, "--region", config.AwsRegion},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = pythonClean.Start()

	// wait `cmd` until it finishes
	_ = pythonClean.Wait()
}
