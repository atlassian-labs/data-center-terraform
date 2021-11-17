package e2etest

import "github.com/gruntwork-io/terratest/modules/k8s"

type TestConfig struct {
	Product         string
	TerraformConfig TerraformConfig
	HelmConfig      HelmConfig
	KubectlConfig   KubectlConfig
	ReleaseName     string
	EnvironmentName string
}

type TerraformConfig struct {
	Variables       map[string]interface{}
	EnvVariables    map[string]string
	TargetModuleDir string
}

type HelmConfig struct {
	SetValues      map[string]string
	KubectlOptions *k8s.KubectlOptions
	ExtraArgs      map[string][]string
}

type KubectlConfig struct {
	ContextName string
	Namespace   string
}
