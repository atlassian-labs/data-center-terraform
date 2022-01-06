package e2etest

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	awsSdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

const defaultConfigFilename = "e2e_test_env_config.json"
const bambooAgentCount = 3 // Set to 3 so that all pods can be scheduled with default resources (i.e. one m5.xlarge node)

func GenerateTerraformOptions(config TerraformConfig, t *testing.T) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: config.TestFolder,
		Vars:         config.Variables,
		EnvVars:      config.EnvVariables,
	})
}

func GenerateKubectlOptions(config KubectlConfig, tfOptions *terraform.Options, environmentName string) *k8s.KubectlOptions {
	return k8s.NewKubectlOptions(config.ContextName, fmt.Sprintf("%s/kubeconfig_atlas-%s-cluster", tfOptions.TerraformDir, environmentName), config.Namespace)
}

func GenerateConfigForProductE2eTest(t *testing.T, product string, customConfigFilename string) EnvironmentConfig {
	if customConfigFilename == "" {
		return GenerateNewConfigForProductE2eTest(t, product, GetAvailableRegion(t))
	}

	return LoadConfigForProductE2eTest(t, customConfigFilename)
}

func GenerateNewConfigForProductE2eTest(t *testing.T, product string, awsRegion string) EnvironmentConfig {
	testResourceOwner := "terraform_e2e_test"
	testId := strings.ToLower(random.UniqueId())
	environmentName := "e2etest-" + testId
	domain := "deplops.com"
	terraformConfig := TerraformConfig{
		Variables: map[string]interface{}{
			"environment_name": environmentName,
			"region":           awsRegion,
			"resource_tags": map[string]string{
				"Name":           environmentName + "-stack",
				"resource_owner": testResourceOwner,
				"Terraform":      "true",
				"business_unit":  "Engineering-Enterprise DC",
				"service_name":   "dc-infrastructure",
				"git_repository": "github.com/atlassian-labs/data-center-terraform",
			},
			"domain":                     domain,
			"bamboo_admin_username":      "admin",
			"bamboo_admin_password":      "admin",
			"bamboo_admin_display_name":  "Admin",
			"bamboo_admin_email_address": "admin@foo.com",
			"number_of_bamboo_agents":    bambooAgentCount,
			"dataset_url":                "https://bamboo-test-datasets.s3.amazonaws.com/testing_dataset_minimal.zip",
		},
		EnvVariables: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		TestFolder: testStructure.CopyTerraformFolderToTemp(t, "../..", "."),
	}
	kubectlConfig := KubectlConfig{
		ContextName: fmt.Sprintf("eks_atlas-%s-cluster", environmentName),
		Namespace:   product,
	}

	return EnvironmentConfig{
		Product:         product,
		AwsRegion:       awsRegion,
		TerraformConfig: terraformConfig,
		KubectlConfig:   kubectlConfig,
		EnvironmentName: environmentName,
	}
}

func LoadConfigForProductE2eTest(t *testing.T, customConfigFilename string) EnvironmentConfig {
	var config EnvironmentConfig
	err := Load("artifacts/"+customConfigFilename, &config)
	require.NoError(t, err)
	return config
}

func GenerateAwsSession(awsRegion string) *session.Session {
	return session.Must(session.NewSession(&awsSdk.Config{
		Region: awsSdk.String(awsRegion),
	}))
}

func K8sDriver(t *testing.T, tfOptions *terraform.Options, environmentName string) *kubernetes.Clientset {
	config, err := clientcmd.BuildConfigFromFlags("", fmt.Sprintf("%s/kubeconfig_atlas-%s-cluster", tfOptions.TerraformDir, environmentName))
	require.NoError(t, err)

	clientset, err := kubernetes.NewForConfig(config)
	require.NoError(t, err)

	return clientset
}

func SafeExtractShareHomeVolume(volumes []v1.Volume) v1.Volume {
	if volumes[1].Name == "shared-home" {
		return volumes[1]
	}
	return volumes[0]
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

func CreateDirIfNotExist(dirName string) error {
	newpath := filepath.Join(".", dirName)
	return os.MkdirAll(newpath, os.ModePerm)
}

func Save(path string, object interface{}) error {
	file, foerr := os.Create(path)
	if foerr != nil {
		return foerr
	}
	defer file.Close()

	json, mrerr := json.Marshal(object)
	if mrerr != nil {
		return mrerr
	}
	_, fwerr := file.Write(json)
	return fwerr
}

func Load(path string, object interface{}) error {
	file, foerr := os.Open(path)
	if foerr != nil {
		return foerr
	}
	defer file.Close()
	bytesHolder, frerr := ioutil.ReadAll(file)
	if frerr != nil {
		return frerr
	}
	return json.Unmarshal(bytesHolder, object)
}

func CopyDir(src string, dst string) (err error) {
	src = filepath.Clean(src)
	dst = filepath.Clean(dst)

	si, err := os.Stat(src)
	if err != nil {
		return err
	}
	if !si.IsDir() {
		return fmt.Errorf("source is not a directory")
	}

	_, err = os.Stat(dst)
	if err != nil && !os.IsNotExist(err) {
		return
	}
	if err == nil {
		// return fmt.Errorf("destination already exists")
	}

	err = os.MkdirAll(dst, si.Mode())
	if err != nil {
		return
	}

	entries, err := ioutil.ReadDir(src)
	if err != nil {
		return
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		if entry.IsDir() {
			if entry.Name() != ".git" {
				err = CopyDir(srcPath, dstPath)
				if err != nil {
					return
				}
			}
		} else {
			// Skip symlinks.
			if entry.Mode()&os.ModeSymlink != 0 {
				continue
			}

			err = CopyFile(srcPath, dstPath)
			if err != nil {
				return
			}
		}
	}

	return
}

func CopyFile(src, dst string) (err error) {
	in, err := os.Open(src)
	if err != nil {
		return
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return
	}
	defer func() {
		if e := out.Close(); e != nil {
			err = e
		}
	}()

	_, err = io.Copy(out, in)
	if err != nil {
		return
	}

	err = out.Sync()
	if err != nil {
		return
	}

	si, err := os.Stat(src)
	if err != nil {
		return
	}
	err = os.Chmod(dst, si.Mode())
	if err != nil {
		return
	}

	return
}
