package e2etest

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/transport/ssh"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"os"
	"os/exec"
	"testing"
)

func bitbucketHealthTests(t *testing.T, testConfig TestConfig) {
	printTestBanner(bitbucket, "Tests")
	assertBitbucketStatusEndpoint(t, testConfig, "RUNNING")
	assertBitbucketNfsConnectivity(t, testConfig)
	assertBitbucketSshConnectivity(t, testConfig)
}

func assertBitbucketStatusEndpoint(t *testing.T, testConfig TestConfig, expectedStatus string) {
	statusUrl := "status"
	url := fmt.Sprintf("https://%s.%s.%s/%s", bitbucket, testConfig.EnvironmentName, domain, statusUrl)
	content := getPageContent(t, url)
	println("Asserting Bitbucket Status Endpoint ...")
	assert.Contains(t, string(content), expectedStatus)
}

func assertBitbucketNfsConnectivity(t *testing.T, testConfig TestConfig) {
	contextName := fmt.Sprintf("eks_atlas-%s-cluster", testConfig.EnvironmentName)
	kubeConfigPath := fmt.Sprintf("../../kubeconfig_atlas-%s-cluster", testConfig.EnvironmentName)
	kubectlOptions := k8s.NewKubectlOptions(contextName, kubeConfigPath, "atlassian")

	// Write a file to the NFS server
	print("Asserting Bitbucket NFS connectivity ...")
	returnCode, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"exec", "bitbucket-nfs-server-0",
		"--", "/bin/bash",
		"-c", "echo \"Greetings from an NFS\" >> $(find /srv/nfs/bitbucket-* | head -1)/nfs-file-share-test.txt; echo $?")

	assert.Nil(t, kubectlError)
	assert.Equal(t, "0", returnCode)

	// Read the file from the Bitbucket pod
	fileContents, kubectlError := k8s.RunKubectlAndGetOutputE(t, kubectlOptions,
		"exec", "bitbucket-0",
		"-c", "bitbucket",
		"--", "/bin/bash",
		"-c", "cat /var/atlassian/application-data/shared-home/nfs-file-share-test.txt")

	assert.Nil(t, kubectlError)
	assert.Equal(t, "Greetings from an NFS", fileContents)
}

func assertBitbucketSshConnectivity(t *testing.T, testConfig TestConfig) {
	println("Asserting Bitbucket SSH connectivity ...")

	// DO the SSH check to automatically add the target host to known hosts.
	host := fmt.Sprintf("%s.%s.%s", bitbucket, testConfig.EnvironmentName, domain)
	sshEndpoint := fmt.Sprintf("ssh://%s:7999", host)
	cmd := exec.Command("ssh", "-v", "-o", "StrictHostKeyChecking=no", sshEndpoint)
	output, _ := cmd.CombinedOutput()

	stdout := string(output)
	assert.Contains(t, stdout, "Connection established")

	addNewSshKey(t, testConfig)
	addNewProject(t, testConfig)
	addNewProjectRepo(t, testConfig)

	url := "git@bitbucket.yzhangssh.deplops.com:7999/bbssh/bitbucket-ssh-test-repo.git"
	var publicKey *ssh.PublicKeys
	sshPath := os.Getenv("HOME") + "/.ssh/id_rsa"
	sshKey, _ := ioutil.ReadFile(sshPath)
	publicKey, keyError := ssh.NewPublicKeys("git", []byte(sshKey), "")
	if keyError != nil {
		fmt.Println(keyError)
	}
	_, err := git.PlainClone("/tmp/foo", false, &git.CloneOptions{
		URL:      url,
		Progress: os.Stdout,
		Auth:     publicKey,
	})
	if err != nil {
		println(err.Error())
	}
}

func addNewProjectRepo(t *testing.T, testConfig TestConfig) {
	println("Create new repo ...")
	credential := fmt.Sprintf("admin:%s", testConfig.BitbucketPassword)
	host := fmt.Sprintf("%s.%s.%s", bitbucket, testConfig.EnvironmentName, domain)
	restEndpoint := fmt.Sprintf("https://%s@%s/rest/api/latest/projects/BBSSH/repos", credential, host)

	addNewRepository, _ := json.Marshal(map[string]string{
		"name":          "Bitbucket SSH test repo",
		"scmId":         "git",
		"defaultBranch": "main",
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addNewRepository))
}

func addNewProject(t *testing.T, testConfig TestConfig) {
	println("Create new project ...")
	credential := fmt.Sprintf("admin:%s", testConfig.BitbucketPassword)
	host := fmt.Sprintf("%s.%s.%s", bitbucket, testConfig.EnvironmentName, domain)
	restEndpoint := fmt.Sprintf("https://%s@%s/rest/api/latest/projects", credential, host)

	addNewProject, _ := json.Marshal(map[string]string{
		"key":         "BBSSH",
		"name":        "Bitbucket SSH test",
		"description": "A project for testing the Bitbucket SSH test",
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addNewProject))
}

func addNewSshKey(t *testing.T, testConfig TestConfig) {
	println("Push public key to Bitbucket server ...")
	pkPath := os.Getenv("HOME") + "/.ssh/id_rsa.pub"
	pk, err := ioutil.ReadFile(pkPath)
	if err != nil {
		fmt.Print(err)
	}

	credential := fmt.Sprintf("admin:%s", testConfig.BitbucketPassword)
	host := fmt.Sprintf("%s.%s.%s", bitbucket, testConfig.EnvironmentName, domain)
	restEndpoint := fmt.Sprintf("https://%s@%s/rest/ssh/latest/keys", credential, host)

	addSshKeyJsonPayload, _ := json.Marshal(map[string]string{
		"text": string(pk),
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addSshKeyJsonPayload))
}
