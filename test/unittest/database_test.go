package unittest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDbVariablesNotProvided(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(nil, t, databaseModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "No value for required variable")
	assert.Contains(t, err.Error(), "\"product\" is not set")
	assert.Contains(t, err.Error(), "\"rds_instance_id\" is not set")
	assert.Contains(t, err.Error(), "\"instance_class\" is not set")
	assert.Contains(t, err.Error(), "\"allocated_storage\" is not set")
	assert.Contains(t, err.Error(), "\"iops\" is not set")
	assert.Contains(t, err.Error(), "\"eks\" is not set")
	assert.Contains(t, err.Error(), "\"vpc\" is not set")
}

func TestDbVariablesPopulatedWithValidValues(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbValidVariable, t, databaseModule)

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
	planUserName := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["username"]
	planEngine := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["engine"]
	planDbName := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["name"]
	planInstanceClass := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["instance_class"]
	planAllocatedStorage := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["allocated_storage"]
	planIops := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["iops"]
	assert.Equal(t, inputRdsInstanceId, planDbIdentifier)
	assert.Equal(t, inputProduct+"user", planUserName)
	assert.Equal(t, "postgres", planEngine)
	assert.Equal(t, inputProduct, planDbName)
	assert.Equal(t, inputInstanceClass, planInstanceClass)
	assert.EqualValues(t, inputAllocatedStorage, planAllocatedStorage)
	assert.EqualValues(t, inputIops, planIops)
}

func TestDbRdsInstanceIdInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbInvalidVariable, t, databaseModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid RDS instance name.")
}
