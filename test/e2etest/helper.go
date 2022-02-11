package e2etest

import (
	"github.com/stretchr/testify/assert"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"text/template"

	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
)

const (
	bambooLicense = ""
	resourceOwner = "dc-deployment"
	credential    = "admin:Atlassian21!" // Admin credential 'username:password'
	product       = "bamboo"
	domain        = "deplops.com"
)

type TestConfig struct {
	AwsRegion       string
	BambooLicense   string
	EnvironmentName string
	ConfigPath      string
	ResourceOwner   string
}

func EnvironmentName() string {
	testId := strings.ToLower(random.UniqueId())
	environmentName := "e2etest-" + testId
	return environmentName
}

func GetAvailableRegion(t *testing.T) string {
	for {
		awsRegion := aws.GetRandomStableRegion(t, nil, []string{
			endpoints.UsEast1RegionID,
			endpoints.UsEast2RegionID,
			endpoints.UsWest1RegionID,
			endpoints.UsWest2RegionID,
			endpoints.AfSouth1RegionID,
			endpoints.ApEast1RegionID,
			endpoints.ApNortheast2RegionID,
			endpoints.ApSoutheast2RegionID,
			endpoints.ApNortheast3RegionID,
		}) // Avoid busy/unavailable regions
		vpcs, err := aws.GetVpcsE(t, nil, awsRegion)
		require.NoError(t, err)

		if len(vpcs) < 4 {
			return awsRegion
		}
		log.Println(awsRegion, " has reached resource limit, Finding new region")
	}
}

func getPageContent(t *testing.T, url string) []byte {
	get, err := http.Get(url)
	require.NoError(t, err, "Error accessing url: %s", url)
	defer get.Body.Close()

	assert.Equal(t, 200, get.StatusCode)
	content, err := io.ReadAll(get.Body)

	assert.NoError(t, err, "Error reading response body")
	return content
}

func sendPostRequest(t *testing.T, url string, contentType string, body io.Reader) {
	resp, err := http.Post(url, contentType, body)
	require.NoError(t, err, "Error accessing url: %s", url)
	defer resp.Body.Close()
}

func createConfig(t *testing.T, productList []string) TestConfig {
	var bambooLicense = bambooLicense
	if len(bambooLicense) == 0 {
		bambooLicense = os.Getenv("TF_VAR_bamboo_license")
	}
	testConfig := TestConfig{
		AwsRegion:       GetAvailableRegion(t),
		BambooLicense:   bambooLicense,
		EnvironmentName: EnvironmentName(),
		ResourceOwner:   resourceOwner,
	}

	// Product list
	products := strings.Join(productList[:], "\",\"")
	if len(products) > 0 {
		products = "\"" + products + "\""
	}

	// variables
	vars := make(map[string]interface{})
	vars["bamboo_license"] = testConfig.BambooLicense
	vars["resource_owner"] = resourceOwner
	vars["environment_name"] = testConfig.EnvironmentName
	vars["region"] = testConfig.AwsRegion
	vars["products"] = products


	// parse the template
	tmpl, _ := template.ParseFiles("test-config.tfvars.tmpl")

	// create a new file
	file, _ := os.Create("test-config.tfvars")
	defer file.Close()

	// apply the template to the vars map and write the result to file.
	err := tmpl.Execute(file, vars)
	require.NoError(t, err, "Error applying template to .tfvars file")

	filePath, _ := filepath.Abs(file.Name())

	testConfig.ConfigPath = filePath
	return testConfig
}
