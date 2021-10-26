package unittest

import (
	"path/filepath"
	"testing"
	"sync"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Helper functions
var lock = &sync.Mutex{}

type PlanStruct struct {
	plan terraform.PlanStruct
}

var vpc_instance *PlanStruct

// Generates the VPC terraform plan for default values of the module
// This is a singleton implementation for the plan
func GetVpcDefaultPlans(t *testing.T) *terraform.PlanStruct {

	lock.Lock()
	defer lock.Unlock()
	if vpc_plan_instance == nil {
		tfOptions := GenerateVpcTFOptions(map[string]interface{}{
			"vpc_name": "test-vpc",
			"vpc_tags": map[string]interface{}{
				"resource_owner": "TestResourceOwner",
			},
		}, t)

		// Run `terraform init`, `terraform plan`, and `terraform show`
		plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
		vpc_instance = &PlanStruct{plan: *plan}
	}

	return &vpc_instance.plan
}

func GenerateVpcTFOptions(variables map[string]interface{}, t *testing.T) *terraform.Options {
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
