package e2etest

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCleanup(t *testing.T) {
	var tfOptions *terraform.Options
	if err := Load("bamboo_tfOptions.json", &tfOptions); err != nil {
		require.NoError(t, err)
	}
	terraform.Destroy(t, tfOptions)
}
