package e2etest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"os/exec"
	"strconv"
	"testing"
)

func TestInstaller(t *testing.T) {

	productList := []string{jira, confluence, bamboo, bitbucket, crowd}
	useDomain, _ := strconv.ParseBool(os.Getenv("USE_DOMAIN"))
	additionalRole := os.Getenv("AWS_ADDITIONAL_ROLE")
	testConfig := createConfig(t, productList, useDomain, additionalRole)

	// Schedule uninstall and cleanup the environment
	// multiple defer statements are executed in LIFO(Last-In, First-Out)
	defer runCleanupScript(testConfig)
	defer runUninstallScript(testConfig.ConfigPath)
	defer gatherK8sLogs(testConfig)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	// run again with same config. This is to assure that the `re-apply` action finishes without any issue.
	runInstallScript(testConfig.ConfigPath)

	clusterHealthTests(t, testConfig)
	checkAGSAndEC2Tags(t, testConfig)
	checkEbsVolumes(t, testConfig)

	productUrls := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")
	crowdDbInfo := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "crowd_database")
	synchronyUrl := terraform.Output(t, &terraform.Options{TerraformDir: "../../"}, "synchrony_url")

	if contains(productList, bamboo) {
		bambooHealthTests(t, testConfig, productUrls[bamboo])
	}

	if contains(productList, jira) {
		jiraHealthTests(t, productUrls[jira])
	}

	if contains(productList, confluence) {
		confluenceHealthTests(t, testConfig, productUrls[confluence], synchronyUrl)
	}

	if contains(productList, bitbucket) {
		bitbucketHealthTests(t, testConfig, productUrls[bitbucket])
	}

	if contains(productList, crowd) {
		crowdTests(t, testConfig, productUrls[bitbucket], productUrls[crowd], crowdDbInfo["jdbc_connection"], useDomain)
	}
}

func runInstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "install.sh",
		Args:   []string{"install.sh", "-l", "-c", configPath, "-f"},
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

func gatherK8sLogs(testConfig TestConfig) {
	printTestBanner("Gathering K8s logs and events from environment ", testConfig.EnvironmentName)

	cmd := &exec.Cmd{
		Path:   "collect_k8s_logs.sh",
		Args:   []string{"collect_k8s_logs.sh", "atlas-" + testConfig.EnvironmentName + "-cluster", testConfig.AwsRegion},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../scripts",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
}

func runCleanupScript(testConfig TestConfig) {
	printTestBanner("Cleaning up AWS resources with tag service_name", testConfig.EnvironmentName)

	cmd := &exec.Cmd{
		Path:   "/usr/bin/python",
		Args:   []string{"python", "aws_clean.py", "--service_name", testConfig.EnvironmentName, "--region", testConfig.AwsRegion},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Env:    []string{"PYTHONPATH=/opt/hostedtoolcache/Python/3.9.14/x64/lib/python3.9/site-packages"},
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
}
