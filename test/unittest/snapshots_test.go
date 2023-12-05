package unittest

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"path/filepath"
	"testing"
)

type DCSnapshots struct {
	JiraEbs       string
	JiraRds       string
	JsmEbs        string
	JsmRds        string
	ConfluenceEbs string
	ConfluenceRds string
	BitbucketEbs  string
	BitbucketRds  string
	CrowdEbs      string
	CrowdRds      string
}

var vars = map[string]interface{}{
	"environment_name":              "e2etests",
	"snapshots_json_file_path":      "test/dcapt-snapshots.json",
	"products":                      []string{"jira", "confluence", "bitbucket", "crowd"},
	"region":                        "us-east-2",
	"jira_version_tag":              "9.4.10",
	"jira_license":                  "license",
	"jira_db_master_username":       "atljira",
	"jira_db_master_password":       "Password1!",
	"confluence_license":            "license",
	"confluence_version_tag":        "7.19.14",
	"confluence_db_master_username": "atlconfluence",
	"confluence_db_master_password": "Password1!",
	"bitbucket_license":             "license",
	"bitbucket_version_tag":         "7.21.16",
	"bitbucket_admin_username":      "admin",
	"bitbucket_admin_password":      "admin",
	"bitbucket_admin_display_name":  "admin",
	"bitbucket_admin_email_address": "admin@example.com",
	"bitbucket_db_master_username":  "atlbitbucket",
	"bitbucket_db_master_password":  "Password1!",
	"crowd_license":                 "license",
	"crowd_version_tag":             "5.1.4",
	"crowd_db_master_username":      "atlcrowd",
	"crowd_db_master_password":      "Password1!",
	"bamboo_license":                "bamboo-license",
	"bamboo_version_tag":            "9.2.3",
	"bamboo_agent_version_tag":      "9.2.3",
	"bamboo_admin_username":         "admin",
	"bamboo_admin_password":         "admin",
	"bamboo_admin_display_name":     "admin",
	"bamboo_admin_email_address":    "admin@example.com",
	"bamboo_dataset_url":            "https://centaurus-datasets.s3.amazonaws.com/bamboo/dcapt-bamboo.zip",
}

func TestJsmSnapshots(t *testing.T) {
	t.Parallel()
	jiraSnapshots := DCSnapshots{
		JsmEbs: "snap-0381cc00e37231565",
		JsmRds: "arn:aws:rds:us-east-2:585036043680:snapshot:dcapt-jsm-5-4-10",
	}
	vars["jira_image_repository"] = "atlassian/jira-servicemanagement"
	vars["jira_version_tag"] = "5.4.10"
	exampleFolder := testStructure.CopyTerraformFolderToTemp(t, "../..", "")
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	planFilePath := filepath.Join(exampleFolder, "plan.out")
	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         vars,
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		PlanFilePath: planFilePath,
	})

	plan, _ := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)
	jsmRdsSnapshot := plan.ResourcePlannedValuesMap["module.jira[0].module.database.data.aws_db_snapshot.confluence_db_snapshot[0]"].AttributeValues["db_snapshot_identifier"]
	jsmEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.jira[0].module.nfs.aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	assert.Equal(t, jiraSnapshots.JsmRds, jsmRdsSnapshot)
	assert.Equal(t, jiraSnapshots.JsmEbs, jsmEbsVolumeSnapshot)
}
func TestSnapshotsFromJson(t *testing.T) {
	t.Parallel()

	// rather than parse the ../dcapt-snapshots.json, snap ids are copied from it
	dcSnapshots := DCSnapshots{
		JiraEbs:       "snap-084e99e384dcfbe31",
		JiraRds:       "arn:aws:rds:us-east-2:585036043680:snapshot:dcapt-jira-9-4-10",
		ConfluenceEbs: "snap-00f5e8147604a017e",
		ConfluenceRds: "arn:aws:rds:us-east-2:585036043680:snapshot:dcapt-confluence-7-19-14",
		BitbucketEbs:  "snap-0d4bbe0cf3056c0ee",
		BitbucketRds:  "arn:aws:rds:us-east-2:585036043680:snapshot:dcapt-bitbucket-7-21-16",
		CrowdEbs:      "snap-0a8e229690be9ae30",
		CrowdRds:      "arn:aws:rds:us-east-2:585036043680:snapshot:dcapt-crowd-5-1-4",
	}

	vars := vars

	// a bit of copy-paste as we can't use GenerateTFOptions as is (we need to run terraform plan in the root of the directory)
	exampleFolder := testStructure.CopyTerraformFolderToTemp(t, "../..", "")
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	planFilePath := filepath.Join(exampleFolder, "plan.out")
	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: exampleFolder,
		Vars:         vars,
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		PlanFilePath: planFilePath,
	})

	plan, _ := terraform.InitAndPlanAndShowWithStructE(t, tfOptions)

	// assert that pre-install jobs are created (rds snapshot id is not null)
	confluencePreInstallJob := plan.ResourcePlannedValuesMap["module.confluence[0].kubernetes_job.pre_install[0]"]
	crowdPreInstallJob := plan.ResourcePlannedValuesMap["module.crowd[0].kubernetes_job.pre_install[0]"]
	bitbucketPreInstallJob := plan.ResourcePlannedValuesMap["module.bitbucket[0].kubernetes_job.pre_install[0]"]
	jiraPreInstallJob := plan.ResourcePlannedValuesMap["module.jira[0].kubernetes_job.pre_install[0]"]

	assert.NotNil(t, confluencePreInstallJob)
	assert.NotNil(t, crowdPreInstallJob)
	assert.NotNil(t, bitbucketPreInstallJob)
	assert.NotNil(t, jiraPreInstallJob)

	// assert that snapshot IDs are in outputs, i.e. they have been correctly extracted from
	// ../dcapt-snapshots.json. Additionally, Confluence and Crowd have build_numbers
	assert.Equal(t, dcSnapshots.BitbucketEbs, plan.RawPlan.PlannedValues.Outputs["bitbucket_ebs_snapshot"].Value)
	assert.Equal(t, dcSnapshots.BitbucketRds, plan.RawPlan.PlannedValues.Outputs["bitbucket_rds_snapshot"].Value)

	assert.Equal(t, dcSnapshots.JiraEbs, plan.RawPlan.PlannedValues.Outputs["jira_ebs_snapshot"].Value)
	assert.Equal(t, dcSnapshots.JiraRds, plan.RawPlan.PlannedValues.Outputs["jira_rds_snapshot"].Value)

	assert.Equal(t, dcSnapshots.ConfluenceEbs, plan.RawPlan.PlannedValues.Outputs["confluence_ebs_snapshot"].Value)
	assert.Equal(t, dcSnapshots.ConfluenceRds, plan.RawPlan.PlannedValues.Outputs["confluence_rds_snapshot"].Value)
	assert.Equal(t, "8804", plan.RawPlan.PlannedValues.Outputs["confluence_db_snapshot_build_number"].Value)

	assert.Equal(t, dcSnapshots.CrowdEbs, plan.RawPlan.PlannedValues.Outputs["crowd_ebs_snapshot"].Value)
	assert.Equal(t, dcSnapshots.CrowdRds, plan.RawPlan.PlannedValues.Outputs["crowd_rds_snapshot"].Value)
	assert.Equal(t, "1893", plan.RawPlan.PlannedValues.Outputs["crowd_db_snapshot_build_number"].Value)

	// assert that RDS snapshots are in db_snapshot data
	confluenceRdsSnapshot := plan.ResourcePlannedValuesMap["module.confluence[0].module.database.data.aws_db_snapshot.confluence_db_snapshot[0]"].AttributeValues["db_snapshot_identifier"]
	bitbucketRdsSnapshot := plan.ResourcePlannedValuesMap["module.bitbucket[0].module.database.data.aws_db_snapshot.confluence_db_snapshot[0]"].AttributeValues["db_snapshot_identifier"]
	crowdRdsSnapshot := plan.ResourcePlannedValuesMap["module.crowd[0].module.database.data.aws_db_snapshot.confluence_db_snapshot[0]"].AttributeValues["db_snapshot_identifier"]
	jiraRdsSnapshot := plan.ResourcePlannedValuesMap["module.jira[0].module.database.data.aws_db_snapshot.confluence_db_snapshot[0]"].AttributeValues["db_snapshot_identifier"]

	assert.Equal(t, dcSnapshots.ConfluenceRds, confluenceRdsSnapshot)
	assert.Equal(t, dcSnapshots.BitbucketRds, bitbucketRdsSnapshot)
	assert.Equal(t, dcSnapshots.CrowdRds, crowdRdsSnapshot)
	assert.Equal(t, dcSnapshots.JiraRds, jiraRdsSnapshot)

	// assert ebs snapshot is in ebs_volume aws resource
	bitbucketEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.bitbucket[0].module.nfs.aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	jiraEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.jira[0].module.nfs.aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	confluenceEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.confluence[0].module.nfs.aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	crowdEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.crowd[0].module.nfs.aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]

	assert.Equal(t, dcSnapshots.BitbucketEbs, bitbucketEbsVolumeSnapshot)
	assert.Equal(t, dcSnapshots.JiraEbs, jiraEbsVolumeSnapshot)
	assert.Equal(t, dcSnapshots.ConfluenceEbs, confluenceEbsVolumeSnapshot)
	assert.Equal(t, dcSnapshots.CrowdEbs, crowdEbsVolumeSnapshot)
}
