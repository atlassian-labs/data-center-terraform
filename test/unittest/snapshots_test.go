package unittest

import (
	"encoding/json"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"testing"
)

type SnapshotDetails struct {
	UsEast2 string `json:"us-east-2"`
	UsEast1 string `json:"us-east-1"`
}

type Data struct {
	Type      string            `json:"type"`
	Size      string            `json:"size"`
	Snapshots []SnapshotDetails `json:"snapshots"`
}

type Version struct {
	Version     string `json:"version"`
	Data        []Data `json:"data"`
	BuildNumber string `json:"build_number"`
}

type Product struct {
	Versions []Version `json:"versions"`
}

type DCSnapshots struct {
	Jira       Product `json:"jira"`
	Jsm        Product `json:"jsm"`
	Confluence Product `json:"confluence"`
	Bitbucket  Product `json:"bitbucket"`
	Crowd      Product `json:"crowd"`
}

var vars = map[string]interface{}{
	"environment_name":              "e2etests",
	"snapshots_json_file_path":      "test/dcapt-snapshots.json",
	"products":                      []string{"jira", "confluence", "bitbucket", "crowd"},
	"region":                        "us-east-2",
	"jira_version_tag":              "9.12.4",
	"jira_license":                  "license",
	"jira_db_master_username":       "atljira",
	"jira_db_master_password":       "Password1!",
	"confluence_license":            "license",
	"confluence_version_tag":        "7.19.19",
	"confluence_db_master_username": "atlconfluence",
	"confluence_db_master_password": "Password1!",
	"bitbucket_license":             "license",
	"bitbucket_version_tag":         "7.21.22",
	"bitbucket_admin_username":      "admin",
	"bitbucket_admin_password":      "admin",
	"bitbucket_admin_display_name":  "admin",
	"bitbucket_admin_email_address": "admin@example.com",
	"bitbucket_db_master_username":  "atlbitbucket",
	"bitbucket_db_master_password":  "Password1!",
	"crowd_license":                 "license",
	"crowd_version_tag":             "5.2.3",
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

func getLargeRdsSnapshot(product Product) *Data {
	if len(product.Versions) > 0 {
		firstVersion := product.Versions[0]
		for _, data := range firstVersion.Data {
			if data.Size == "large" && data.Type == "rds" {
				return &data
			}
		}
	}
	return nil
}

func getLargeEbsSnapshot(product Product) *Data {
	if len(product.Versions) > 0 {
		firstVersion := product.Versions[0]
		for _, data := range firstVersion.Data {
			if data.Size == "large" && data.Type == "ebs" {
				return &data
			}
		}
	}
	return nil
}

func getLargeLocalHomeSnapshot(product Product) *Data {
	if len(product.Versions) > 0 {
		firstVersion := product.Versions[0]
		for _, data := range firstVersion.Data {
			if data.Size == "large" && data.Type == "local-home" {
				return &data
			}
		}
	}
	return nil
}

func fetchSnapshotsJson() (*DCSnapshots, error) {
	url := "https://raw.githubusercontent.com/atlassian/dc-app-performance-toolkit/master/app/util/k8s/dcapt-snapshots.json"
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch data: %v", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %v", err)
	}

	f, err := os.Create("../dcapt-snapshots.json")
	if err != nil {
		return nil, err
	}
	defer f.Close()
	_, err = f.Write(body)
	if err != nil {
		return nil, err
	}

	var snapshots DCSnapshots
	if err := json.Unmarshal(body, &snapshots); err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}
	return &snapshots, nil
}

func TestJsmSnapshots(t *testing.T) {
	t.Parallel()
	dcSnapshots, err := fetchSnapshotsJson()
	assert.NoError(t, err)
	vars["jira_image_repository"] = "atlassian/jira-servicemanagement"
	vars["jira_version_tag"] = dcSnapshots.Jsm.Versions[0].Version
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
	jsmRdsSnapshot := plan.ResourcePlannedValuesMap["module.database[0].module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"]
	assert.NotNil(t, jsmRdsSnapshot)
	jsmEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.nfs[0].aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	assert.NotNil(t, jsmEbsVolumeSnapshot)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Jsm).Snapshots[0].UsEast2, jsmRdsSnapshot)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Jsm).Snapshots[0].UsEast2, jsmEbsVolumeSnapshot)
}

func TestSnapshotsFromJson(t *testing.T) {
	t.Parallel()

	dcSnapshots, err := fetchSnapshotsJson()
	assert.NoError(t, err)
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

	// assert that snapshot IDs are in outputs, i.e. they have been correctly extracted from ../dcapt-snapshots.json
	// Additionally, Confluence and Crowd have build_numbers

	// Bitbucket tests
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Bitbucket).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["bitbucket_ebs_snapshot"].Value)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Bitbucket).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["bitbucket_rds_snapshot"].Value)

	// Jira tests
	assert.Equal(t, getLargeLocalHomeSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["jira_local_home_snapshot"].Value)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["jira_ebs_snapshot"].Value)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["jira_rds_snapshot"].Value)

	// Confluence tests
	assert.Equal(t, getLargeLocalHomeSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["confluence_local_home_snapshot"].Value)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["confluence_ebs_snapshot"].Value)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["confluence_rds_snapshot"].Value)
	assert.Equal(t, dcSnapshots.Confluence.Versions[0].BuildNumber, plan.RawPlan.PlannedValues.Outputs["confluence_db_snapshot_build_number"].Value)

	// Crowd tests
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Crowd).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["crowd_ebs_snapshot"].Value)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Crowd).Snapshots[0].UsEast2, plan.RawPlan.PlannedValues.Outputs["crowd_rds_snapshot"].Value)
	assert.Equal(t, dcSnapshots.Crowd.Versions[0].BuildNumber, plan.RawPlan.PlannedValues.Outputs["crowd_db_snapshot_build_number"].Value)

	// assert that the right RDS snapshots are in the right database modules
	jiraRdsSnapshot := plan.ResourcePlannedValuesMap["module.database[0].module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"]
	confluenceRdsSnapshot := plan.ResourcePlannedValuesMap["module.database[1].module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"]
	bitbucketRdsSnapshot := plan.ResourcePlannedValuesMap["module.database[2].module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"]
	crowdRdsSnapshot := plan.ResourcePlannedValuesMap["module.database[3].module.db.module.db_instance.aws_db_instance.this[0]"].AttributeValues["snapshot_identifier"]

	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, confluenceRdsSnapshot)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Bitbucket).Snapshots[0].UsEast2, bitbucketRdsSnapshot)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Crowd).Snapshots[0].UsEast2, crowdRdsSnapshot)
	assert.Equal(t, getLargeRdsSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, jiraRdsSnapshot)

	// assert ebs and local home snapshots are in ebs_volume aws resources
	jiraEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.nfs[0].aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	confluenceEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.nfs[1].aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	bitbucketEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.nfs[2].aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]
	crowdEbsVolumeSnapshot := plan.ResourcePlannedValuesMap["module.nfs[3].aws_ebs_volume.shared_home"].AttributeValues["snapshot_id"]

	jiraEbsLocalSnapshot := plan.ResourcePlannedValuesMap["module.jira[0].aws_ebs_volume.local_home[0]"].AttributeValues["snapshot_id"]
	confluenceEbsLocalSnapshot := plan.ResourcePlannedValuesMap["module.confluence[0].aws_ebs_volume.local_home[0]"].AttributeValues["snapshot_id"]

	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Bitbucket).Snapshots[0].UsEast2, bitbucketEbsVolumeSnapshot)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, jiraEbsVolumeSnapshot)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, confluenceEbsVolumeSnapshot)
	assert.Equal(t, getLargeEbsSnapshot(dcSnapshots.Crowd).Snapshots[0].UsEast2, crowdEbsVolumeSnapshot)

	// assert local home snap ids
	assert.Equal(t, getLargeLocalHomeSnapshot(dcSnapshots.Confluence).Snapshots[0].UsEast2, confluenceEbsLocalSnapshot)
	assert.Equal(t, getLargeLocalHomeSnapshot(dcSnapshots.Jira).Snapshots[0].UsEast2, jiraEbsLocalSnapshot)
}
