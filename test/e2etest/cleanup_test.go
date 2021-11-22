package e2etest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCleanup(t *testing.T) {
	var environmentConfig EnvironmentConfig

	if *customConfigFilename == "" {
		err := Load("artifacts/"+defaultConfigFilename, &environmentConfig)
		require.NoError(t, err)
	} else {
		err := Load("artifacts/"+(*customConfigFilename), &environmentConfig)
		require.NoError(t, err)
	}

	tfOptions := GenerateTerraformOptions(environmentConfig.TerraformConfig, t)
	terraform.Destroy(t, tfOptions)
}
