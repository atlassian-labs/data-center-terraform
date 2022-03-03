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

	host := fmt.Sprintf("%s.%s.%s", bitbucket, testConfig.EnvironmentName, domain)
	credential := fmt.Sprintf("admin:%s", testConfig.BitbucketPassword)

	// Check connections over ssh to port 7999 are working
	addTestHostToKnownHosts(t, host)

	// Now let's do some real work..
	addNewSshKey(t, host, credential)
	addNewProject(t, host, credential)
	addNewRepo(t, host, credential)
	cloneRepo(t, host)
}

func addTestHostToKnownHosts(t *testing.T, host string) {
	println(fmt.Sprintf("Adding %s to known_hosts ...", host))
	cmd := exec.Command("ssh-keyscan", "-p", "7999", host, ">", "/home/runner/.ssh/known_hosts")
	output, _ := cmd.CombinedOutput()

	stdout := string(output)
	println(stdout)
	assert.Contains(t, stdout, fmt.Sprintf("%s:7999", host))
}

func addNewSshKey(t *testing.T, host string, credential string) {
	println("Push public key to Bitbucket server ...")
	pkPath := os.Getenv("HOME") + "/.ssh/bitbucket-e2e.pub"
	pk, err := ioutil.ReadFile(pkPath)
	if err != nil {
		println(fmt.Print(err.Error()))
	}

	restEndpoint := fmt.Sprintf("https://%s@%s/rest/ssh/latest/keys", credential, host)

	addSshKeyJsonPayload, _ := json.Marshal(map[string]string{
		"text": string(pk),
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addSshKeyJsonPayload))
	content := getPageContent(t, restEndpoint)
	publicKey := "AAAAB3NzaC1yc2EAAAADAQABAAACAQDjfTvP42K+jhLm729U896GDAy16XlGc2OxRLjKf3eBquiVM4iZ+GOGWTxsjmyP7TEfBXGAjTde/0xv2HzBzRUlx6c1XvqQ8pNNpXdO0QDZTj0DOAxaRsfKSOzw9LAR9dcf5u2tkXfRDjWvfl/9i8+gn4Vz9WBkTo7+RzpDEHebj/1chKSDzeyMJuuTQeukxtsEWTbYjWIYKkckbWxhN8jpN2FAAqaV8c3wrfvBlFPJ02t+solxlUpx/Qo7NgQIJyRfVoGtyhHmB4OAwl6pbDZAXb0iK5Im3oP5pAL8Wsx5RjEI7Zt/7PBhbBPskEHjAZBdyBDh0mk5FzziMbKXNcPJq10lISMsDNh1cHLjJoEWPPoXsDGFjxAy+cdv/V+8zImHQA8frPZGx8tXGV7twP+6o57TEVf3uQeUcfSE6l1CKauVAL+MrxRbQBaUit7+w8uazoE4AHrRydraD0/aTAGaUMN9BicMdy5j5Utl5zwjrG/XxW8eljspJA1I7Py1FbaRoGmNyV3aRfh9Cq5Bet8XFE8n383nPYejzIwYz8OSJaj8xoPpOuoDQlEaj3pPV5OOUDVHq6ehjH8ClbSGM02TB4OAQYeHa3PdcJd39H3vPdKfG1DNQAIpqPj25aLnE7zuT68p0JXsMGreCLRooJsTEfjHPXDqldk1NpqjRYyryw=="
	assert.Contains(t, string(content), publicKey)
}

func addNewProject(t *testing.T, host string, credential string) {
	println("Create new project ...")
	restEndpoint := fmt.Sprintf("https://%s@%s/rest/api/latest/projects", credential, host)

	addNewProject, _ := json.Marshal(map[string]string{
		"key":         "BBSSH",
		"name":        "Bitbucket SSH test",
		"description": "A project for testing the Bitbucket SSH test",
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addNewProject))
	content := getPageContent(t, restEndpoint)
	projectDescription := "A project for testing the Bitbucket SSH test"
	assert.Contains(t, string(content), projectDescription)
}

func addNewRepo(t *testing.T, host string, credential string) {
	println("Create new repo ...")
	restEndpoint := fmt.Sprintf("https://%s@%s/rest/api/latest/projects/BBSSH/repos", credential, host)

	addNewRepository, _ := json.Marshal(map[string]string{
		"name":          "Bitbucket SSH test repo",
		"scmId":         "git",
		"defaultBranch": "main",
	})

	sendPostRequest(t, restEndpoint, "application/json", bytes.NewBuffer(addNewRepository))
	content := getPageContent(t, restEndpoint)
	sshCloneUrl := fmt.Sprintf("ssh://git@%s:7999/bbssh/bitbucket-ssh-test-repo.git", host)
	assert.Contains(t, string(content), sshCloneUrl)
}

func cloneRepo(t *testing.T, host string) {
	println("Clone repo ...")
	cloneUrl := fmt.Sprintf("git@%s:7999/bbssh/bitbucket-ssh-test-repo.git", host)
	var publicKey *ssh.PublicKeys
	sshPath := os.Getenv("HOME") + "/.ssh/bitbucket-e2e"
	sshKey, _ := ioutil.ReadFile(sshPath)
	publicKey, keyError := ssh.NewPublicKeys("git", []byte(sshKey), "")
	if keyError != nil {
		fmt.Println(keyError)
	}
	_, err := git.PlainClone("/tmp/cloned", false, &git.CloneOptions{
		URL:      cloneUrl,
		Progress: os.Stdout,
		Auth:     publicKey,
	})
	assert.Error(t, err)
	assert.Equal(t, "remote repository is empty", err.Error())
}

func TestSsh(t *testing.T) {
	addTestHostToKnownHosts(t, "bitbucket.yzhangssh.deplops.com")
	addNewSshKey(t, "bitbucket.yzhangssh.deplops.com", "sshadmin:admin!ssh")
	cloneRepo(t, "bitbucket.yzhangssh.deplops.com")
}
