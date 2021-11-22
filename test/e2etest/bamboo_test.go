package e2etest

import (
	"context"
	"flag"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	awsSdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/eks"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var customConfigFilename = flag.String("config", "", "Name of test environment config file")

func TestBambooModule(t *testing.T) {

	environmentConfig := GenerateConfigForProductE2eTest(t, "bamboo", *customConfigFilename)
	tfOptions := GenerateTerraformOptions(environmentConfig.TerraformConfig, t)
	kubectlOptions := GenerateKubectlOptions(environmentConfig.KubectlConfig, tfOptions, environmentConfig.EnvironmentName)

	if *customConfigFilename == "" {
		creationErr := CreateDirIfNotExist("artifacts")
		require.NoError(t, creationErr)
		saveErr := Save("artifacts/"+defaultConfigFilename, environmentConfig)
		require.NoError(t, saveErr)
	}

	terraform.InitAndApply(t, tfOptions)

	vpcOutput := getVpcOutput(t, tfOptions)

	assertVPC(t, environmentConfig.AwsRegion, vpcOutput, environmentConfig.EnvironmentName)
	assertEKS(t, environmentConfig.AwsRegion, vpcOutput, environmentConfig.EnvironmentName)
	assertShareHomePV(t, tfOptions, environmentConfig.EnvironmentName, environmentConfig.Product)
	assertShareHomePVC(t, tfOptions, environmentConfig.EnvironmentName, environmentConfig.Product)
	assertBambooPod(t, kubectlOptions, environmentConfig.Product)
	assertIngressAccess(t, environmentConfig.Product, environmentConfig.EnvironmentName, fmt.Sprintf("%v", environmentConfig.TerraformConfig.Variables["domain"]))
	assertRDS(t, tfOptions, kubectlOptions, environmentConfig.AwsRegion, environmentConfig.Product)
}

func assertVPC(t *testing.T, awsRegion string, vpcOutput VpcOutput, environmentName string) {
	vpc := aws.GetVpcById(t, vpcOutput.Id, awsRegion)
	assert.Equal(t, fmt.Sprintf("atlassian-dc-%s-vpc", environmentName), vpc.Name)
	assert.Len(t, vpc.Subnets, 4)
}

func assertEKS(t *testing.T, awsRegion string, vpcOutput VpcOutput, environmentName string) {
	session := GenerateAwsSession(awsRegion)
	eksClient := eks.New(session)
	describeClusterInput := &eks.DescribeClusterInput{
		Name: awsSdk.String(fmt.Sprintf("atlassian-dc-%s-cluster", environmentName)),
	}

	eksInfo, err := eksClient.DescribeCluster(describeClusterInput)
	require.NoError(t, err)

	assert.Equal(t, vpcOutput.Id, *((*eksInfo).Cluster.ResourcesVpcConfig.VpcId))
}

func assertShareHomePV(t *testing.T, tfOptions *terraform.Options, environmentName string, product string) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	k8sClient := K8sDriver(t, tfOptions, environmentName)
	pvClient := k8sClient.CoreV1().PersistentVolumes()

	_, err := pvClient.Get(ctx, fmt.Sprintf("atlassian-dc-%s-share-home-pv", product), v1.GetOptions{})
	require.NoError(t, err)
}

func assertShareHomePVC(t *testing.T, tfOptions *terraform.Options, environmentName string, product string) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	k8sClient := K8sDriver(t, tfOptions, environmentName)
	pvcClient := k8sClient.CoreV1().PersistentVolumeClaims(product)

	_, err := pvcClient.Get(ctx, fmt.Sprintf("atlassian-dc-%s-share-home-pvc", product), v1.GetOptions{})
	require.NoError(t, err)
}

func assertBambooPod(t *testing.T, kubectlOptions *k8s.KubectlOptions, product string) {
	podName := fmt.Sprintf("%s-0", product)
	pod := k8s.GetPod(t, kubectlOptions, podName)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, 5, 30*time.Second)
	shareHomeVolume := SafeExtractShareHomeVolume(pod.Spec.Volumes)

	assert.Equal(t, true, pod.Status.ContainerStatuses[0].Ready)
	assert.Equal(t, fmt.Sprintf("atlassian-dc-%s-share-home-pvc", product), shareHomeVolume.PersistentVolumeClaim.ClaimName)
}

func assertIngressAccess(t *testing.T, product string, environment string, domain string) {
	path := "setup/setupLicense.action"
	expectedContent := "Welcome to Bamboo Data Center"
	url := fmt.Sprintf("https://%s.%s.%s/%s", product, environment, domain, path)
	fmt.Printf("testing url: %s", url)
	get, err := http.Get(url)
	require.NoError(t, err)

	defer get.Body.Close()

	assert.NoError(t, err, "Error accessing url: %s", url)
	assert.Equal(t, 200, get.StatusCode)

	content, err := io.ReadAll(get.Body)

	assert.NoError(t, err, "Error reading response body")
	assert.Contains(t, string(content), expectedContent)
}

func assertRDS(t *testing.T, tfOptions *terraform.Options, kubectlOptions *k8s.KubectlOptions, awsRegion string, product string) {
	dbOutput := databaseOutput{}
	terraform.OutputStruct(t, tfOptions, "database", &dbOutput)
	dbInstanceID := dbOutput.RdsInstanceId
	dbName := dbOutput.DbName

	endpoint := aws.GetAddressOfRdsInstance(t, dbInstanceID, awsRegion)
	port := aws.GetPortOfRdsInstance(t, dbInstanceID, awsRegion)

	assert.NotNil(t, endpoint)
	assert.Equal(t, int64(5432), port)

	// Get password
	secretName := product + "-db-cred"
	secret, secretErr := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "get", "secret", secretName, "-o", "jsonpath='{.data.password}'")
	assert.Nil(t, secretErr)
	assert.NotNil(t, secret)
	decSecret, decodeErr := base64.StdEncoding.DecodeString(secret[1 : len(secret)-1])
	assert.Nil(t, decodeErr)
	password := string(decSecret)

	// Assert DB connection
	psqlClientPodName := "e2e-test-psqlclient"
	username := product + "user"

	_, psqlClientErr := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "run", psqlClientPodName,
		"--image=tmaier/postgresql-client", "--command", "--", "/bin/sh", "-c", "tail -f /dev/null")
	if psqlClientErr != nil && strings.Contains(psqlClientErr.Error(), "AlreadyExists") {
		psqlClientErr = nil
	}
	assert.Nil(t, psqlClientErr)

	ExpectedStatus := "success"
	status := retry.DoWithRetry(t, "Waiting for DB connection validation...", 5, time.Duration(time.Second*5),
		func() (string, error) {
			output, execErr := k8s.RunKubectlAndGetOutputE(t, kubectlOptions, "exec", psqlClientPodName,
				"--", "/bin/sh",
				"-c", fmt.Sprintf("PGPASSWORD=\"%s\" psql \"sslmode=require host=%s dbname=%s user=%s\" -q -c \"SELECT version()\" > test.log;echo $?;",
					password, endpoint, dbName, username),
			)
			if execErr != nil {
				return "", execErr
			}

			t.Log("PostgresClient:", output)
			if output == "0" {
				return ExpectedStatus, nil
			} else {
				return "", fmt.Errorf("fail")
			}
		})
	assert.Equal(t, ExpectedStatus, status)

}

func getVpcOutput(t *testing.T, tfOptions *terraform.Options) VpcOutput {
	vpcOutput := VpcOutput{}
	terraform.OutputStruct(t, tfOptions, "vpc", &vpcOutput)
	fmt.Printf("VpcOutput struct: %+v\n", vpcOutput)
	return vpcOutput
}
