package unittest

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Helper function
func GenerateTFOptions(variables map[string]interface{}, t *testing.T) *terraform.Options {
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../../pkg", "/modules/AWS/vpc")
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	planFilePath := filepath.Join(exampleFolder, "plan.out")

	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         variables,
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		PlanFilePath: planFilePath,
	})

	return tfOptions
}
