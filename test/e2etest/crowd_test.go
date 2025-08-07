package e2etest

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"strings"
	"testing"
	"text/template"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func getAtlToken(t *testing.T, bitbucketURL string, sessionID string) (atlToken string) {
	client := &http.Client{}
	request, err := http.NewRequest(http.MethodGet, bitbucketURL+"/plugins/servlet/embedded-crowd/configure/crowd/", nil)
	require.NoError(t, err, "Error creating GET request")
	cookie := &http.Cookie{Name: "BITBUCKETSESSIONID", Value: sessionID}
	request.AddCookie(cookie)

	get, err := client.Do(request)
	require.NoError(t, err, "Error accessing url")
	defer get.Body.Close()

	content, _ := io.ReadAll(get.Body)
	reader := bytes.NewReader(content)
	doc, err := goquery.NewDocumentFromReader(reader)
	require.NoError(t, err, "Error processing HTML page")
	// Find the input field with name="atl_token" and extract its value
	atlToken = doc.Find("input[name='atl_token']").AttrOr("value", "")
	return atlToken
}

func setUserGlobalPermissions(t *testing.T, bitbucketURL string, sessionID string, userName string, permissions string) {
	log.Printf("Granting %s permissions for user %s\n", permissions, userName)

	client := &http.Client{}
	request, _ := http.NewRequest(http.MethodPut, fmt.Sprintf("%s/admin/permissions/users?permission=%s&name=%s", bitbucketURL, permissions, userName), nil)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")
	cookie := &http.Cookie{Name: "BITBUCKETSESSIONID", Value: sessionID}
	request.AddCookie(cookie)
	resp, _ := client.Do(request)
	assert.Equal(t, 204, resp.StatusCode)
}

func createNewCrowdUser(t *testing.T, userName string, crowdURL string, openIdServerPassword string) {
	log.Printf("Creating user %s\n", userName)
	client := &http.Client{}
	jsonStr := fmt.Sprintf(`{"name":"%s","first-name":"%s","last-name":"%s","display-name":"%s","email":"%s@example.test","password":{"value":"password"},"active":true}`, userName, userName, userName, userName, userName)
	request, err := http.NewRequest(http.MethodPost, crowdURL+"/rest/usermanagement/latest/user", bytes.NewBuffer([]byte(jsonStr)))
	assert.NoError(t, err)
	request.Header.Set("Content-Type", "application/json")
	request.SetBasicAuth("crowd-openid-server", openIdServerPassword)
	resp, err := client.Do(request)
	assert.NoError(t, err)
	assert.Equal(t, 201, resp.StatusCode)
}

func addCrowdUserDirectory(t *testing.T, directoryName string, bitbucketURL string, crowdURL string, crowdPassword string, bitbucketSessionID string, atlToken string) {
	log.Printf("Creating Crowd User Directory: %s\n", directoryName)
	client := &http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	formData := url.Values{
		"name":                                []string{"Crowd " + directoryName},
		"crowdServerUrl":                      []string{crowdURL},
		"applicationName":                     []string{"crowd-openid-server"},
		"applicationPassword":                 []string{crowdPassword},
		"crowdPermissionOption":               []string{"READ_ONLY"},
		"_nestedGroupsEnabled":                []string{"visible"},
		"incrementalSyncEnabled":              []string{"true"},
		"_incrementalSyncEnabled":             []string{"visible"},
		"groupSyncOnAuthMode":                 []string{"ALWAYS"},
		"crowdServerSynchroniseIntervalInMin": []string{"1"},
		"save":                                []string{"Save and Test"},
		"atl_token":                           []string{atlToken},
		"directoryId":                         []string{"0"},
	}
	encodedData := formData.Encode()
	request, err := http.NewRequest(http.MethodPost, bitbucketURL+"/plugins/servlet/embedded-crowd/configure/crowd/", strings.NewReader(encodedData))
	require.NoError(t, err)
	request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	cookie := &http.Cookie{Name: "BITBUCKETSESSIONID", Value: bitbucketSessionID}
	request.AddCookie(cookie)
	_, err = client.Do(request)
	require.NoError(t, err)
}

func getBitbucketSessionID(bitbucketURL string, username string, password string) (sessionID string, err error) {
	jar, err := cookiejar.New(nil)
	if err != nil {
		return "", fmt.Errorf("error creating cookie jar: %v", err)
	}
	client := &http.Client{
		Jar: jar,
	}
	payload := map[string]interface{}{
		"username":   username,
		"password":   password,
		"rememberMe": true,
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("error encoding JSON payload: %v", err)
	}
	request, err := http.NewRequest(http.MethodPost, bitbucketURL+"/rest/tsv/1.0/authenticate", bytes.NewReader(payloadBytes))
	if err != nil {
		return "", fmt.Errorf("error creating request: %v", err)
	}
	request.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(request)
	if err != nil {
		return "", fmt.Errorf("error making request: %v", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		if body, err := ioutil.ReadAll(resp.Body); err != nil {
			log.Printf("Error reading response body: %v", err)
		} else {
			log.Printf("Login failed: %s", string(body))
		}
		return "", fmt.Errorf("authentication failed: status code %d", resp.StatusCode)
	}
	cookies := jar.Cookies(request.URL)
	for _, cookie := range cookies {
		if cookie.Name == "BITBUCKETSESSIONID" {
			return cookie.Value, nil
		}
	}

	return "", fmt.Errorf("BITBUCKETSESSIONID not found in response")
}

func generateCrowdCfgXml(t *testing.T, testConfig TestConfig, jdbcURL string, rdsPassword string) {

	vars := make(map[string]interface{})
	vars["crowd_rds_password"] = rdsPassword
	vars["crowd_jdbc_url"] = jdbcURL
	vars["crowd_license"] = testConfig.CrowdLicense

	// parse the template
	tmpl, _ := template.ParseFiles("crowd-backup/crowd.cfg.xml.tpl")

	// create a new file
	file, _ := os.Create("crowd.cfg.xml")
	defer file.Close()

	// apply the template to the vars map and write the result to file.
	err := tmpl.Execute(file, vars)
	require.NoError(t, err, "Error applying template to crowd.cfg.xml file")
}

func restoreCrowdFromBackup(t *testing.T, testConfig TestConfig, jdbcURL string) {

	kubectlOptions := getKubectlOptions(t, testConfig)

	// extract rds hostname from jdbc url
	start := strings.Index(jdbcURL, "://") + len("://")
	end := strings.Index(jdbcURL[start:], ":") + start
	rdsHostname := jdbcURL[start:end]

	// get postgres password from a secret
	base64EncPassword, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "get", "secrets", "crowd-db-cred", "-n", "atlassian", "-o", "jsonpath={.data.password}")
	require.NoError(t, kubectlError)
	decodedPassword, _ := base64.StdEncoding.DecodeString(base64EncPassword)

	// generate crowd.cfg.xml from a template, replace postgres details and license
	generateCrowdCfgXml(t, testConfig, jdbcURL, string(decodedPassword))

	// create a pod with psql client from which the DB will be restored
	log.Print("Creating postgres client pod")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"run", "postgres-client", "--restart=Never", "--image", "docker.io/bitnami/postgresql:14.3.0-debian-10-r20",
		"--env", "PGPASSWORD="+string(decodedPassword)+"", "-n", "atlassian",
		"--", "tail", "-f", "/dev/null")
	assert.Nil(t, kubectlError)

	// wait for pod to be running to make sure we can exec and cp into it
	log.Print("Waiting for postgres client pod to be ready")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"wait", "pods", "postgres-client", "-n", "atlassian", "--for", "condition=Ready", "--timeout=120s")
	assert.Nil(t, kubectlError)

	// copy sql dump file to postgres-client pod
	log.Print("Copying sql dump file to the postgres client pod")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "cp", "crowd-backup/crowd.sql", "atlassian/postgres-client:/opt/crowd.sql", "-n", "atlassian")
	assert.Nil(t, kubectlError)

	// restore crowd database from dump file
	log.Printf("Restoring database %s from dump file\n", rdsHostname)
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"exec", "postgres-client", "-n", "atlassian",
		"--", "/bin/sh",
		"-c", "psql --host "+rdsHostname+" -U postgres -p 5432 -d crowd < /opt/crowd.sql")
	assert.Nil(t, kubectlError)

	// delete postgres-client pod otherwise Terraform will fail to delete the namespace
	log.Print("Deleting postgres-client pod")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"delete", "pod", "postgres-client", "-n", "atlassian", "--force", "--grace-period=0")
	assert.Nil(t, kubectlError)

	// copy processed crowd.cfg.xml file to crowd shared home
	log.Print("Copying crowd.cfg.xml to crowd pod")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "cp", "crowd.cfg.xml", "atlassian/crowd-0:/var/atlassian/application-data/crowd/shared/crowd.cfg.xml", "-n", "atlassian")
	assert.Nil(t, kubectlError)

	// rollout restart crowd StatefulSet so that the copied crowd.cfg.xml is found
	log.Print("Restarting crowd pod")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "rollout", "restart", "sts/crowd", "-n", "atlassian")
	assert.Nil(t, kubectlError)

	// wait for crowd deployment to pass readiness probe
	log.Print("Waiting for crowd pod to be ready")
	_, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "rollout", "status", "sts/crowd", "-n", "atlassian", "--timeout=300s")
	assert.Nil(t, kubectlError)

	// if calls to crowd are made right away, occasional 503 errors are possible
	// giving Crowd extra 10 seconds fixes it, however, looking at the correctness
	// of crowd readiness probe is a better idea
	time.Sleep(10 * time.Second)
}

func crowdTests(t *testing.T, testConfig TestConfig, bitbucketURL string, crowdURL string, jdbcURL string, useDomain bool) {
	printTestBanner(crowd, "Tests")

	if useDomain {
		crowdURL = crowdURL + "/crowd"
	}

	restoreCrowdFromBackup(t, testConfig, jdbcURL)

	userNameBase := "user"
	userName := fmt.Sprintf("%s-%s", userNameBase, testConfig.EnvironmentName)
	createNewCrowdUser(t, userName, crowdURL, testConfig.CrowdPassword)

	// before making calls to Bitbucket make sure we land on the same node and avoid using sticky cookie in requests
	// scale bitbucket to 1 replica instead of 3.
	log.Print("Scaling Bitbucket to 1")
	_, kubectlError := k8s.RunKubectlAndGetOutputE(t, getKubectlOptions(t, testConfig), "scale", "sts/bitbucket", "-n", "atlassian", "--replicas=1")
	assert.Nil(t, kubectlError)
	// we need to give Bitbucket some time to unregister Hazelcast nodes and update cluster setting
	time.Sleep(15 * time.Second)

	// get BITBUCKETSESSIONID to use in the header in subsequent calls
	// even though basic auth works, atl_token is different each time
	bitbucketSessionID, err := getBitbucketSessionID(bitbucketURL, "admin", testConfig.BitbucketPassword)
	assert.Nil(t, err)
	assert.NotEmptyf(t, bitbucketSessionID, "BITBUCKETSESSIONID cannot be empty")

	// now we need to extract atl_token from the hidden input in HTML response
	// we will try 5 times, as token is extracted from html output and the test proved
	// to be quite flaky as the token was missing
	atlToken := getAtlToken(t, bitbucketURL, bitbucketSessionID)
	if atlToken == "" {
		log.Printf("atl_token is empty. Retrying in 5 seconds")
		time.Sleep(5 * time.Second)
		atlToken = getAtlToken(t, bitbucketURL, bitbucketSessionID)
	}

	assert.NotEmptyf(t, atlToken, "atl_token cannot be empty")

	// add a new user directory in Bitbucket
	addCrowdUserDirectory(t, testConfig.EnvironmentName, bitbucketURL, crowdURL, testConfig.CrowdPassword, bitbucketSessionID, atlToken)
	// even though sync interval is set to 1 minute, it roughly takes 2-3 mins
	// to sync user directory for the first time. Increase the sleep if tests are unstable
	log.Printf("Waiting for Crowd User Directory %s to be synced\n", userName)
	time.Sleep(150 * time.Second)

	// we set ADMIN permissions so that the new user is allowed to call APIs
	setUserGlobalPermissions(t, bitbucketURL, bitbucketSessionID, userName, "ADMIN")

	// now let's call project api with the new user credentials
	log.Printf("Checking if user %s is allowed to call Bitbucket project API\n", userName)
	projects := getPageContentWithBasicAuth(t, bitbucketURL+"/rest/api/latest/projects", userName, "password")
	var result map[string]interface{}
	err = json.Unmarshal(projects, &result)
	require.NoError(t, err)
	// tests create 1 project, so we expect 1
	// if auth fails, API returns json with size=0
	assert.Equal(t, float64(1), result["size"])
}
