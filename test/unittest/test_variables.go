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

var VpcDefaultModuleVariable = map[string]interface{}{
	"vpc_id":                      "dummy_vpc_id",
	"private_subnets":             []interface{}{"subnet1", "subnet2"},
	"private_subnets_cidr_blocks": []interface{}{"10.0.0.0/22", "10.0.4.0/22"},
	"public_subnets":              []interface{}{"subnet1-pub", "subnet2-pub"},
	"public_subnets_cidr_blocks":  []interface{}{"111.0.0.0/22", "111.0.4.0/22"},
}

// EKS

var EksWithValidValues = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
}

var EksWithInvalidClusterName = map[string]interface{}{
	"cluster_name": "cluster name with invalid spaces",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
}

var EksWithDesiredCapacityOverLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 11,
}

var EksDesiredCapacityUnderLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},

	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 0,
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
	"vpc":                          VpcDefaultModuleVariable,
	"csi_controller_replica_count": 1,
}

var EfsInvalidVariable = map[string]interface{}{
	"efs_name":                     "test-efs",
	"region_name":                  "invalid-region",
	"eks":                          EksDefaultModuleVariable,
	"vpc":                          VpcDefaultModuleVariable,
	"csi_controller_replica_count": 1,
}

// NFS
const nfsVarNamespace = "test-name-space"
const nfsVarChartNameOverride = "test-nfs-override-name"
const nfsVarCapacity = "10Gi"
const nfsRequestsCpu = "0.25"
const nfsRequestsMemory = "256Mi"
const nfsLimitsCpu = "0.25"
const nfsLimitsMemory = "256Mi"

var NfsValidVariable = map[string]interface{}{
	"namespace":       nfsVarNamespace,
	"chart_name":      nfsVarChartNameOverride,
	"capacity":        nfsVarCapacity,
	"requests_cpu":    nfsRequestsCpu,
	"requests_memory": nfsRequestsMemory,
	"limits_cpu":      nfsLimitsCpu,
	"limits_memory":   nfsLimitsMemory,
}

// DB
const databaseModule = "AWS/rds"
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

var BitbucketInvalidVariables = map[string]interface{}{
	"environment_name": "1-is-an-invalid-environment-name",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
		"cluster_size":           2,
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "13",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	"admin_configuration": map[string]interface{}{
		"invalid":             "dummy_admin_username",
		"admin_password":      "dummy_admin_password",
		"admin_display_name":  "dummy_admin_display_name",
		"admin_email_address": "dummy_admin_email_address",
	},
	"display_name": superLongStr,
	"ingress":      map[string]interface{}{},
	"bitbucket_configuration": map[string]interface{}{
		"helm_version": "1.2.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"license":      "dummy_license",
		"invalid":      "bitbucket-configuration",
	},
	"nfs_requests_cpu":       "0.25",
	"nfs_requests_memory":    "256Mi",
	"nfs_limits_cpu":         "0.25",
	"nfs_limits_memory":      "256Mi",
	"elasticsearch_cpu":      "1",
	"elasticsearch_mem":      "1Gi",
	"elasticsearch_storage":  10,
	"elasticsearch_replicas": 9, // invalid, should be [2,8]
}

var superLongStr = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam orci mauris, cursus sit amet tortor sit amet, aliquam dapibus magna. In sodales felis in ipsum euismod tempor. Phasellus mattis, justo id auctor lacinia, ipsum nulla sodales massa, ac porttitor arcu sem et quam."
