package e2etest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCleanup(t *testing.T) {
	var environmentConfig EnvironmentConfig

	if *reuseFileName == "" {
		err := Load(e2eTestEnvConfigFileName, &environmentConfig)
		require.NoError(t, err)
	} else {
		err := Load(*reuseFileName, &environmentConfig)
		require.NoError(t, err)
	}

	tfOptions := GenerateTerraformOptions(environmentConfig.TerraformConfig, t)
	terraform.Destroy(t, tfOptions)
}
