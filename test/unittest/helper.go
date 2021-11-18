package unittest

import (
	"path/filepath"
	"sync"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Helper functions
var lock = &sync.Mutex{}

type PlanStruct struct {
	plan terraform.PlanStruct
}

var vpcPlanInstance *PlanStruct

// Generates the VPC terraform plan for default values of the module
// This is a singleton implementation for the plan
func GetVpcDefaultPlans(t *testing.T) *terraform.PlanStruct {

	lock.Lock()
	defer lock.Unlock()
	if vpcPlanInstance == nil {
		tfOptions := GenerateTFOptions(DefaultVpc, t, "vpc")

		// Run `terraform init`, `terraform plan`, and `terraform show`
		plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
		vpcPlanInstance = &PlanStruct{plan: *plan}
	}

	return &vpcPlanInstance.plan
}

func GenerateTFOptions(variables map[string]interface{}, t *testing.T, module string) *terraform.Options {
	exampleFolder := testStructure.CopyTerraformFolderToTemp(t, "../../pkg/modules/AWS", "/"+module)
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
