package e2etest

import (
	"os"
	"os/exec"
	"testing"
)

func TestInstaller(t *testing.T) {

	testConfig := createConfig(t)

	// Install the environment
	runInstallScript(testConfig.ConfigPath)

	// Run bamboo health tests
	bambooHealthTests(t, testConfig)

	// Uninstall and cleanup the environment
	runUninstallScript(testConfig.ConfigPath)
}

func runInstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "install.sh",
		Args:   []string{"install.sh", "-c", configPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
}

func runUninstallScript(configPath string) {
	cmd := &exec.Cmd{
		Path:   "uninstall.sh",
		Args:   []string{"uninstall.sh", "-c", configPath, "-f"},
		Stdout: os.Stdout,
		Stderr: os.Stdout,
		Dir:    "../../",
	}

	// run `cmd` in background
	_ = cmd.Start()

	// wait `cmd` until it finishes
	_ = cmd.Wait()
}


