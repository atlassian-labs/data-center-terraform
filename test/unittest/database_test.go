package unittest

import (
	"fmt"
	"strconv"
	"strings"
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
	assert.Contains(t, err.Error(), "\"rds_instance_identifier\" is not set")
	assert.Contains(t, err.Error(), "\"instance_class\" is not set")
	assert.Contains(t, err.Error(), "\"allocated_storage\" is not set")
	assert.Contains(t, err.Error(), "\"iops\" is not set")
	//assert.Contains(t, err.Error(), "\"eks\" is not set")
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

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.security_group.aws_security_group_rule.ingress_with_cidr_blocks[0]")
	planVpcCidr := plan.ResourcePlannedValuesMap["module.security_group.aws_security_group_rule.ingress_with_cidr_blocks[0]"].AttributeValues["cidr_blocks"]
	assert.Equal(t, vpcCidrBlock, planVpcCidr)

	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.db.module.db_instance.aws_db_instance.this[0]")
	planDbIdentifier := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["identifier"]
	planUserName := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["username"]
	planEngine := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["engine"]
	planDbName := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["db_name"]
	planInstanceClass := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["instance_class"]
	planAllocatedStorage := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["allocated_storage"]
	planIops := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["iops"]
	planApplyImmediately := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["apply_immediately"]
	assert.Equal(t, inputRdsInstanceId, planDbIdentifier)
	assert.Equal(t, "postgres", planUserName)
	assert.Equal(t, "postgres", planEngine)
	assert.Equal(t, dbName, planDbName)
	assert.Equal(t, inputInstanceClass, planInstanceClass)
	assert.EqualValues(t, inputAllocatedStorage, planAllocatedStorage)
	assert.EqualValues(t, inputIops, planIops)
	assert.EqualValues(t, true, planApplyImmediately)
}

func TestDbVariablesWithoutSnapshot(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbValidVariable, t, databaseModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)

	assert.Nil(t, plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"])
}

func TestDbPostgresVersionMap(t *testing.T) {
	t.Parallel()

	DbValidVariable["major_engine_version"] = dbVersion

	DbValidVariableWithDBVersion := DbValidVariable

	tfOptions := GenerateTFOptions(DbValidVariableWithDBVersion, t, databaseModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	planDbVersion := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["engine_version"]

	assert.True(t, strings.Contains(fmt.Sprintf("%v", planDbVersion), strconv.Itoa(dbVersion)))

}

func TestDbRdsInstanceIdInvalid(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbInvalidVariable, t, databaseModule)

	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Invalid RDS instance name.")
}

func TestDbWithMasterPassword(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbVariableWithDBMasterPassword, t, databaseModule)

	plan := terraform.InitAndPlanAndShowWithStruct(t, tfOptions)
	planDbMasterPwd := plan.ResourcePlannedValuesMap["module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["password"]
	assert.Equal(t, masterPwd, planDbMasterPwd)
}

func TestDbWithInvalidMasterPassword(t *testing.T) {
	t.Parallel()

	tfOptions := GenerateTFOptions(DbVariableWithInvalidDBMasterPassword, t, databaseModule)
	_, err := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	assert.NotNil(t, err)
	assert.Contains(t, err.Error(), "Master password must be at least 8 characters long and can include any")
}
