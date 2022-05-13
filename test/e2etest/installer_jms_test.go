package e2etest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"strconv"
	"testing"
)

func TestJSMInstaller(t *testing.T) {

	productList := []string{jira}
	useDomain, _ := strconv.ParseBool(os.Getenv("USE_DOMAIN"))
	testConfig := createConfig(t, productList, useDomain, true)

	// Schedule uninstall and cleanup the environment
	defer runUninstallScript(testConfig.ConfigPath)

	printTestBanner("AWS test region -", testConfig.AwsRegion)

	runInstallScript(testConfig.ConfigPath)

	clusterHealthTests(t, testConfig)

	productUrls := terraform.OutputMap(t, &terraform.Options{TerraformDir: "../../"}, "product_urls")

	if contains(productList, jira) {
		jiraHealthTests(t, productUrls[jira])
	}
}
