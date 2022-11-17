package e2etest

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"text/template"

	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	resourceOwner = "dc-deployment"
	domain        = "deplops.com"

	// List of supported products
	jira       = "jira"
	confluence = "confluence"
	bitbucket  = "bitbucket"
	bamboo     = "bamboo"

	// License for the products
	confluenceLicense = ""
	bitbucketLicense  = ""
	bambooLicense     = ""

	// If there is a change in the computational requests, this value should be updated
	expectedNumberOfNodes = 2
)

type TestConfig struct {
	AwsRegion         string
	EnvironmentName   string
	ConfigPath        string
	ResourceOwner     string
	AdditionalRole    string
	ConfluenceLicense string
	BitbucketLicense  string
	BambooLicense     string
	BambooPassword    string
	BitbucketPassword string
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

func getPageContentWithBasicAuth(t *testing.T, url string, username string, password string) []byte {
	client := &http.Client{}

	request, err := http.NewRequest(http.MethodGet, url, nil)
	require.NoError(t, err, "Error creating GET request")

	request.SetBasicAuth(username, password)

	get, err := client.Do(request)
	require.NoError(t, err, "Error accessing url: %s", url)
	defer get.Body.Close()

	assert.Equal(t, 200, get.StatusCode)
	content, err := io.ReadAll(get.Body)

	assert.NoError(t, err, "Error reading response body")
	return content
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

func sendPostRequest(t *testing.T, url string, contentType string, username string, password string, body io.Reader) {
	client := &http.Client{}

	request, err := http.NewRequest(http.MethodPost, url, body)
	require.NoError(t, err, "Error creating POST request")

	request.Header.Add("Content-Type", contentType)
	request.SetBasicAuth(username, password)

	resp, err := client.Do(request)
	assert.Regexp(t, "20[01]", strconv.Itoa(resp.StatusCode))

	require.NoError(t, err, "Error accessing url: %s", url)
	defer resp.Body.Close()
}

func getLicense(productList []string, product string) string {
	license := ""
	if contains(productList, product) {
		switch product {
		case confluence:
			license = confluenceLicense
		case bitbucket:
			license = bitbucketLicense
		case bamboo:
			license = bambooLicense
		}
		if len(license) == 0 {
			license = os.Getenv(fmt.Sprintf("TF_VAR_%s_license", product))
		}
	}
	return license
}

func getPassword(productList []string, product string) string {
	password := ""
	if contains(productList, product) {
		password = os.Getenv(fmt.Sprintf("TF_VAR_%s_admin_password", product))
	}
	return password
}

func createConfig(t *testing.T, productList []string, useDomain bool, additionalRole string) TestConfig {

	testConfig := TestConfig{
		AwsRegion:         GetAvailableRegion(t),
		EnvironmentName:   EnvironmentName(),
		ResourceOwner:     resourceOwner,
		AdditionalRole:    additionalRole,
		ConfluenceLicense: getLicense(productList, confluence),
		BitbucketLicense:  getLicense(productList, bitbucket),
		BambooLicense:     getLicense(productList, bamboo),
		BambooPassword:    getPassword(productList, bamboo),
		BitbucketPassword: getPassword(productList, bitbucket),
	}

	// Product list
	products := strings.Join(productList[:], "\",\"")
	if len(products) > 0 {
		products = "\"" + products + "\""
	}

	// variables
	vars := make(map[string]interface{})
	vars["resource_owner"] = resourceOwner
	vars["additional_role"] = testConfig.AdditionalRole
	vars["environment_name"] = testConfig.EnvironmentName
	vars["region"] = testConfig.AwsRegion
	vars["products"] = products
	vars["confluence_license"] = testConfig.ConfluenceLicense
	vars["bitbucket_license"] = testConfig.BitbucketLicense
	vars["bamboo_license"] = testConfig.BambooLicense
	vars["bamboo_password"] = testConfig.BambooPassword
	vars["bitbucket_password"] = testConfig.BitbucketPassword
	if useDomain {
		vars["domain"] = domain
		vars["jsm"] = true // This is to cover jsw and jsm in the existing 2 tests to save time and cost.
	}

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

func getKubectlOptions(t *testing.T, testConfig TestConfig) *k8s.KubectlOptions {
	accountID := aws.GetAccountId(t)
	contextName := fmt.Sprintf("arn:aws:eks:%s:%s:cluster/atlas-%s-cluster", testConfig.AwsRegion, accountID, testConfig.EnvironmentName)
	kubeConfigPath := fmt.Sprintf("../../kubeconfig_atlas-%s-cluster", testConfig.EnvironmentName)
	kubectlOptions := k8s.NewKubectlOptions(contextName, kubeConfigPath, "atlassian")
	return kubectlOptions
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func printTestBanner(text1 string, text2 string) {
	println(fmt.Sprintf("################## %s %s ##################", text1, text2))
}
