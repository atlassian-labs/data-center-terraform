package e2etest

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/transport/ssh"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
)

func bitbucketHealthTests(t *testing.T, testConfig TestConfig, productUrl string) {

	printTestBanner(bitbucket, "Tests")
	assertBitbucketStatusEndpoint(t, productUrl)
	assertBitbucketNfsConnectivity(t, testConfig)
	assertBitbucketSshConnectivity(t, testConfig, productUrl)
}

func assertBitbucketStatusEndpoint(t *testing.T, productUrl string) {
	println("Asserting Bitbucket Status Endpoint ...")

	url := fmt.Sprintf("%s/status", productUrl)
	content := getPageContent(t, url)
	assert.Contains(t, string(content), "RUNNING")
}

func assertBitbucketNfsConnectivity(t *testing.T, testConfig TestConfig) {
	println("Asserting Bitbucket NFS connectivity ...")

	kubectlOptions := getKubectlOptions(t, testConfig)

	// Write a file to the NFS server
	output, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"exec", "bitbucket-nfs-server-0",
		"--", "/bin/bash",
		"-c", "echo \"Greetings from an NFS\" >> $(find /srv/nfs/ | head -1)/nfs-file-share-test.txt; echo $?")

	assert.Nil(t, kubectlError)
	assert.Equal(t, "0", output)

	// Read the file from the Bitbucket pod
	output, kubectlError = k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"exec", "bitbucket-0",
		"-c", "bitbucket",
		"--", "/bin/bash",
		"-c", "cat /var/atlassian/application-data/shared-home/nfs-file-share-test.txt")

	assert.Nil(t, kubectlError)
	assert.Equal(t, "Greetings from an NFS", output)
}

func assertBitbucketSshConnectivity(t *testing.T, testConfig TestConfig, productUrl string) {
	host := getHostFrom(productUrl)

	println("Asserting Bitbucket SSH connectivity ...")

	addServerToKnownHosts(t, host)
	addPublicKeyToServer(t, testConfig.BitbucketPassword, productUrl)
	createNewProject(t, testConfig.BitbucketPassword, productUrl)
	createNewRepo(t, testConfig.BitbucketPassword, productUrl, host)
	cloneRepo(t, host)
}

func addServerToKnownHosts(t *testing.T, host string) {

	println(fmt.Sprintf("Adding %s to known_hosts ...", host))

	cmd := exec.Command("ssh-keyscan", "-t", "rsa", "-p 7999", host)
	output, _ := cmd.CombinedOutput()

	stdout := string(output)
	println(fmt.Sprintf("Keyscan found this public key: %s", stdout))
	assert.Contains(t, stdout, fmt.Sprintf("%s:7999", host))

	err := ioutil.WriteFile(os.Getenv("HOME")+"/.ssh/known_hosts", []byte(stdout), 0644)
	assert.Nil(t, err)
}

func addPublicKeyToServer(t *testing.T, password string, productUrl string) {
	println("Push public key to Bitbucket server ...")

	/* When these tests are executed via Github actions the RSA key
	   (priv/pub) "bitbucket-e2e" is added to the test host via the
	   Github workflow "e2e-test".

	   When running these tests locally you can either update this key
	   to an existing one on your filesystem or generate a dedicated
	   one using "ssh-keygen -t rsa -b 4096 -C "<email>"
	*/
	publicKeyPath := os.Getenv("HOME") + "/.ssh/bitbucket-e2e.pub"
	publicKey, err := ioutil.ReadFile(publicKeyPath)
	assert.Nil(t, err)

	restEndpoint := fmt.Sprintf("%s/rest/ssh/latest/keys", productUrl)
	addSshKeyJsonPayload, _ := json.Marshal(map[string]string{
		"text": string(publicKey),
	})

	sendPostRequest(t, restEndpoint, "application/json", "admin", password, bytes.NewBuffer(addSshKeyJsonPayload))
	content := getPageContentWithBasicAuth(t, restEndpoint, "admin", password)
	publicKeyComponents := strings.Fields(string(publicKey))
	publicKeyString := publicKeyComponents[1]
	assert.Contains(t, string(content), publicKeyString)
}

func createNewProject(t *testing.T, password string, productUrl string) {
	println("Create new project ...")

	restEndpoint := fmt.Sprintf("%s/rest/api/latest/projects", productUrl)
	addNewProject, _ := json.Marshal(map[string]string{
		"key":         "BBSSH",
		"name":        "Bitbucket SSH test",
		"description": "A project for testing the Bitbucket SSH test",
	})

	sendPostRequest(t, restEndpoint, "application/json", "admin", password, bytes.NewBuffer(addNewProject))
	content := getPageContentWithBasicAuth(t, restEndpoint, "admin", password)
	assert.Contains(t, string(content), "A project for testing the Bitbucket SSH test")
}

func createNewRepo(t *testing.T, password string, productUrl string, host string) {
	println("Create new repo ...")

	restEndpoint := fmt.Sprintf("%s/rest/api/latest/projects/BBSSH/repos", productUrl)
	addNewRepository, _ := json.Marshal(map[string]string{
		"name":          "Bitbucket SSH test repo",
		"scmId":         "git",
		"defaultBranch": "main",
	})

	sendPostRequest(t, restEndpoint, "application/json", "admin", password, bytes.NewBuffer(addNewRepository))
	content := getPageContentWithBasicAuth(t, restEndpoint, "admin", password)
	sshCloneUrl := fmt.Sprintf("ssh://git@%s:7999/bbssh/bitbucket-ssh-test-repo.git", host)
	assert.Contains(t, string(content), sshCloneUrl)
}

func cloneRepo(t *testing.T, host string) {
	println("Clone repo ...")

	/* When these tests are executed via Github actions the RSA key
	   (priv/pub) "bitbucket-e2e" is added to the test host via the
	   Github workflow "e2e-test".

	   When running these tests locally you can either update this key
	   to an existing one on your filesystem or generate a dedicated
	   one using "ssh-keygen -t rsa -b 4096 -C "<email>"
	*/
	sshKeyPath := os.Getenv("HOME") + "/.ssh/bitbucket-e2e"
	sshKey, _ := ioutil.ReadFile(sshKeyPath)
	publicKey, keyError := ssh.NewPublicKeys("git", sshKey, "")
	assert.Nil(t, keyError)
	cloneUrl := fmt.Sprintf("git@%s:7999/bbssh/bitbucket-ssh-test-repo.git", host)

	_, err := git.PlainClone("/tmp/cloned", false, &git.CloneOptions{
		URL:      cloneUrl,
		Progress: os.Stdout,
		Auth:     publicKey,
	})
	assert.Error(t, err)
	assert.Equal(t, "remote repository is empty", err.Error())
}

func getHostFrom(productUrl string) string {
	return strings.Split(productUrl, "/")[2]
}
