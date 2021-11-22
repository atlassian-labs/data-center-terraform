package unittest

const TestResourceOwner = "terraform_unit_test"

// VPC

var DefaultVpc = map[string]interface{}{
	"vpc_name": "test-vpc",
}

var VpcWithCustomisedCidr = map[string]interface{}{
	"vpc_name": "test-vpc",
	"vpc_cidr": "10.0.0.0/20",
}

var VpcWithoutName = map[string]interface{}{}

var VpcWithInvalidName = map[string]interface{}{
	"vpc_name": "test-vpc/12",
}

var VpcWithInvalidCidr = map[string]interface{}{
	"vpc_name": "test-vpc",
	"vpc_cidr": "10.0.0.0/0",
}

var VpcDefaultModuleVarialbe = map[string]interface{}{
	"vpc_id":                      "dummy_vpc_id",
	"private_subnets":             []interface{}{"subnet1", "subnet2"},
	"private_subnets_cidr_blocks": []interface{}{"10.0.0.0/22", "10.0.4.0/22"},
}

// EKS

var EksWithValidValues = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
	"ingress_domain":   "test.deplops.com", // needs to be a real domain otherwise this test will fail
}

var EksWithInvalidClusterName = map[string]interface{}{
	"cluster_name": "cluster name with invalid spaces",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
	"ingress_domain":   "ingress.domain.com",
}

var EksWithDesiredCapacityOverLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 11,
	"ingress_domain":   "ingress.domain.com",
}

var EksDesiredCapacityUnderLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 0,
	"ingress_domain":   "ingress.domain.com",
}

var EksDefaultModuleVariable = map[string]interface{}{
	"cluster_name":            "dummy-cluster",
	"cluster_id":              "dummy-cluster-id",
	"cluster_oidc_issuer_url": "http://dummy-oidc.aws.com",
	"kubernetes_provider_config": map[string]interface{}{
		"host":                   "dummy-host",
		"token":                  "dummy-token",
		"cluster_ca_certificate": "dummy-certificate",
	},
}

// EFS

var EfsValidVariable = map[string]interface{}{
	"efs_name":                     "test-efs",
	"region_name":                  "us-east-1",
	"eks":                          EksDefaultModuleVariable,
	"vpc":                          VpcDefaultModuleVarialbe,
	"csi_controller_replica_count": 1,
}

var EfsInvalidVariable = map[string]interface{}{
	"efs_name":                     "test-efs",
	"region_name":                  "invalid-region",
	"eks":                          EksDefaultModuleVariable,
	"vpc":                          VpcDefaultModuleVarialbe,
	"csi_controller_replica_count": 1,
}

// DB
const databaseModule = "rds"
const inputVpcId = "dummy_vpc_id"

var inputSubnets = []interface{}{"subnet1", "subnet2"}

const inputSourceSgId = "dummy-source-sg"
const inputProduct = "bamboo"
const inputRdsInstanceId = "dummy-rds-instance-id"
const inputInstanceClass = "dummy.instance.class"
const inputAllocatedStorage = 100
const inputIops = 1000

const invalidInputRdsInstanceId = "1-"

var DbValidVariable = map[string]interface{}{
	"product":           inputProduct,
	"rds_instance_id":   inputRdsInstanceId,
	"instance_class":    inputInstanceClass,
	"allocated_storage": inputAllocatedStorage,
	"iops":              inputIops,
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": inputSourceSgId,
	},
	"vpc": map[string]interface{}{
		"vpc_id":          inputVpcId,
		"private_subnets": inputSubnets,
	},
}

var DbInvalidVariable = map[string]interface{}{
	"product":           inputProduct,
	"rds_instance_id":   invalidInputRdsInstanceId,
	"instance_class":    inputInstanceClass,
	"allocated_storage": inputAllocatedStorage,
	"iops":              inputIops,
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
	},
	"vpc": map[string]interface{}{
		"vpc_id":          inputVpcId,
		"private_subnets": inputSubnets,
	},
}
