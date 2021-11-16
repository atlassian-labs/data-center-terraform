package e2etest

import "github.com/gruntwork-io/terratest/modules/k8s"

type TestConfig struct {
	terraformConfig TerraformConfig
	helmConfig      HelmConfig
	kubectlConfig   KubectlConfig
	releaseName     string
	environmentName string
}

type TerraformConfig struct {
	variables       map[string]interface{}
	envVariables    map[string]string
	targetModuleDir string
}

type HelmConfig struct {
	setValues      map[string]string
	KubectlOptions *k8s.KubectlOptions
	ExtraArgs      map[string][]string
}

type KubectlConfig struct {
	contextName string
	namespace   string
}
