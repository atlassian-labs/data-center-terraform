package unittest

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

const databaseModule = "database"

func TestDbVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, databaseModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"vpc_id\" is not set")
	assert.Contains(t, err.Error(), "\"subnets\" is not set")
	assert.Contains(t, err.Error(), "\"source_sg\" is not set")
	assert.Contains(t, err.Error(), "\"product\" is not set")
	assert.Contains(t, err.Error(), "\"rds_instance_id\" is not set")
	assert.Contains(t, err.Error(), "\"db_tags\" is not set")
}

func TestDbVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	inputVpcId := "dummy_vpc_id"
	inputSubnets := []interface{}{"subnet1", "subnet2"}
	inputSourceSgId := "dummy-source-sg"
	inputProduct := "bamboo"
	inputRdsInstanceId := "dummy-rds-instance-id"

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_id":          inputVpcId,
		"subnets":         inputSubnets,
		"source_sg":       inputSourceSgId,
		"product":         inputProduct,
		"rds_instance_id": inputRdsInstanceId,
		"db_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"eks": map[string]interface{}{
			"kubernetes_provider_config": map[string]interface{}{
				"host":                   "dummy-token",
				"token":                  "dummy-token",
				"cluster_ca_certificate": "dummy-certificate",
			},
		},
	}, t, databaseModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.security_group.aws_security_group.this_name_prefix[0]")
	planVpcId := plan.ResourcePlannedValuesMap["module.security_group.aws_security_group.this_name_prefix[0]"].AttributeValues["vpc_id"]
	assert.Equal(t, inputVpcId, planVpcId)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.db.module.db_subnet_group.aws_db_subnet_group.this[0]")
	planSubnets := plan.ResourcePlannedValuesMap["module.db.module.db_subnet_group.aws_db_subnet_group.this[0]"].AttributeValues["subnet_ids"]
	assert.EqualValues(t, inputSubnets, planSubnets)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.security_group.aws_security_group_rule.ingress_with_source_security_group_id[0]")
	planSourceSgId := plan.ResourcePlannedValuesMap["module.security_group.aws_security_group_rule.ingress_with_source_security_group_id[0]"].AttributeValues["source_security_group_id"]
	assert.Equal(t, inputSourceSgId, planSourceSgId)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.db.module.db_instance.aws_db_instance.this[0]")
	planDbIdentifier := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["identifier"]
	assert.Equal(t, inputRdsInstanceId, planDbIdentifier)

}

func TestDbRdsInstanceIdInvalid(t *testing.T) {
	t.Parallel()

	inputVpcId := "dummy_vpc_id"
	inputSubnets := []interface{}{"subnet1", "subnet2"}
	inputSourceSgId := "dummy-source-sg"
	inputProduct := "bamboo"
	InvalidInputRdsInstanceId := "1-"

	tfOptions := GenerateTFOptions(map[string]interface{}{
		"vpc_id":          inputVpcId,
		"subnets":         inputSubnets,
		"source_sg":       inputSourceSgId,
		"product":         inputProduct,
		"rds_instance_id": InvalidInputRdsInstanceId,
		"db_tags": map[string]interface{}{
			"resource_owner": TestResourceOwner,
		},
		"eks": map[string]interface{}{
			"kubernetes_provider_config": map[string]interface{}{
				"host":                   "dummy-token",
				"token":                  "dummy-token",
				"cluster_ca_certificate": "dummy-certificate",
			},
		},
	}, t, databaseModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid RDS instance name.")
}
