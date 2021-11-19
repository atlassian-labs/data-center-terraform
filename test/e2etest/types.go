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
type VpcOutput struct {
	Id                 string   `json:"id"`
	PrivateSubnets     []string `json:"private_subnets"`
	PublicSubnets      []string `json:"public_subnets"`
	PrivateSubnetsCidr []string `json:"private_subnets_cidr"`
	PublicSubnetsCidr  []string `json:"public_subnets_cidr"`
}
