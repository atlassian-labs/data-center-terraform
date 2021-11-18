package e2etest

type EnvironmentConfig struct {
	Product         string
	AwsRegion       string
	TerraformConfig TerraformConfig
	KubectlConfig   KubectlConfig
	ReleaseName     string
	EnvironmentName string
}

type TerraformConfig struct {
	Variables       map[string]interface{}
	EnvVariables    map[string]string
	TargetModuleDir string
}

type KubectlConfig struct {
	ContextName string
	Namespace   string
}

// VpcDetails encapsulate terraform VPC output value
type VpcDetails struct {
	id                 string
	privateSubnets     []string
	publicSubnets      []string
	privateSubnetsCidr []string
	publicSubnetsCidr  []string
}
