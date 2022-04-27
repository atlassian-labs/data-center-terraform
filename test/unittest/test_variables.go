package unittest

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
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 1,
	"max_cluster_capacity": 10,
}

var EksWithInvalidClusterName = map[string]interface{}{
	"cluster_name": "cluster name with invalid spaces",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 1,
	"max_cluster_capacity": 10,
}

var EksWithMaxCapacityOverLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 1,
	"max_cluster_capacity": 21,
}

var EksWithMaxCapacityUnderLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 1,
	"max_cluster_capacity": 0,
}

var EksWithMinCapacityUnderLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 0,
	"max_cluster_capacity": 10,
}

var EksWithMinCapacityOverLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"region":       "us-east-1",

	"instance_types":       []string{"instance_type1", "instance_type2"},
	"min_cluster_capacity": 21,
	"max_cluster_capacity": 10,
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

// NFS
const nfsVarNamespace = "test-name-space"
const nfsVarChartNameOverride = "test-nfs-override-name"
const nfsSharedHomeSize = "10Gi"
const nfsRequestsCpu = "0.25"
const nfsRequestsMemory = "256Mi"
const nfsLimitsCpu = "0.25"
const nfsLimitsMemory = "256Mi"
const nfsPvc = productName + "-nfs-pvc"
const productName = "dummy-product"

var NfsValidVariable = map[string]interface{}{
	"namespace":         nfsVarNamespace,
	"chart_name":        nfsVarChartNameOverride,
	"shared_home_size":  nfsSharedHomeSize,
	"requests_cpu":      nfsRequestsCpu,
	"requests_memory":   nfsRequestsMemory,
	"limits_cpu":        nfsLimitsCpu,
	"limits_memory":     nfsLimitsMemory,
	"availability_zone": "dummy-az",
	"product":           productName,
}

// DB
const databaseModule = "AWS/rds"
const inputVpcId = "dummy_vpc_id"

var inputSubnets = []interface{}{"subnet1", "subnet2"}

const inputSourceSgId = "dummy-source-sg"
const inputProduct = "bamboo"
const inputRdsInstanceId = "dummy-rds-instance-id"
const inputRdsSnapshotId = "dummy-rds-snapshot-id"
const inputInstanceClass = "dummy.instance.class"
const inputAllocatedStorage = 100
const inputIops = 1000
const dbVersion = 13
const masterPwd = "dummyPassword!"
const invalidInputRdsInstanceId = "1-"
const dbName = "duumy_name"

var DbValidVariable = map[string]interface{}{
	"product":                 inputProduct,
	"rds_instance_identifier": inputRdsInstanceId,
	"instance_class":          inputInstanceClass,
	"allocated_storage":       inputAllocatedStorage,
	"iops":                    inputIops,
	"db_name":                 dbName,
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
	"snapshot_identifier": inputRdsSnapshotId,
}

var DbVariableWithDBMasterPassword = map[string]interface{}{
	"product":                 inputProduct,
	"rds_instance_identifier": inputRdsInstanceId,
	"instance_class":          inputInstanceClass,
	"allocated_storage":       inputAllocatedStorage,
	"iops":                    inputIops,
	"db_name":                 dbName,
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
	"snapshot_identifier": inputRdsSnapshotId,
	"db_master_password":  masterPwd,
}

var DbInvalidVariable = map[string]interface{}{
	"product":                 inputProduct,
	"rds_instance_identifier": invalidInputRdsInstanceId,
	"instance_class":          inputInstanceClass,
	"allocated_storage":       inputAllocatedStorage,
	"iops":                    inputIops,
	"db_name":                 dbName,
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

var DbVariableWithInvalidDBMasterPassword = map[string]interface{}{
	"product":                 inputProduct,
	"rds_instance_identifier": inputRdsInstanceId,
	"instance_class":          inputInstanceClass,
	"allocated_storage":       inputAllocatedStorage,
	"iops":                    inputIops,
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
	"snapshot_identifier": inputRdsSnapshotId,
	"db_master_password":  "123@",
}

// Bitbucket

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
	"db_name":                 "dummy_db_name",

	"admin_configuration": map[string]interface{}{
		"invalid":             "dummy_admin_username",
		"admin_password":      "dummy_admin_password",
		"admin_display_name":  "dummy_admin_display_name",
		"admin_email_address": "dummy_admin_email_address",
	},
	"display_name":  superLongStr,
	"ingress":       map[string]interface{}{},
	"replica_count": 1,
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

// Confluence

var ConfluenceInvalidVariables = map[string]interface{}{
	"environment_name": "invalid?environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
	},
	"vpc": VpcDefaultModuleVariable,
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"db_major_engine_version": "11",
	"db_configuration": map[string]interface{}{
		"db_allocated_storage": 5,
		"db_instance_class":    "dummy_db_instance_class",
		"db_iops":              1000,
		"db_name":              "dummy_db_name",
		"invalid_db_config":    "extra",
	},
	"replica_count": 1,
	"confluence_configuration": map[string]interface{}{
		"helm_version": "1.1.0",
		"cpu":          "1",
		"mem":          "1Gi",
		"min_heap":     "256m",
		"max_heap":     "512m",
		"license_abc":  "dummy_license", //invalid var name
	},
	"enable_synchrony":         false,
	"db_snapshot_id":           "dummy-snapshot-id",
	"db_master_password":       "dummyPassword!",
	"db_snapshot_build_number": "invalid.build.number",
}

// Jira

var JiraCorrectVariables = map[string]interface{}{
	"environment_name": "dummy-environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
		"availability_zone":      "dummy-az",
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "12",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	"db_name":                 "jira",
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"replica_count": 1,
	"jira_configuration": map[string]interface{}{
		"helm_version":        "1.0.0",
		"cpu":                 "2",
		"mem":                 "2Gi",
		"min_heap":            "384m",
		"max_heap":            "786m",
		"reserved_code_cache": "512m",
		"license":             "dummy_license",
	},
	"db_master_password":     "dummy_password",
	"db_master_username":     "dummy_username",
	"db_snapshot_identifier": "dummy-rds-snapshot-id",
}

var JiraInvalidVariables = map[string]interface{}{
	"environment_name": "invalid?environment",
	"namespace":        "dummy-namespace",
	"eks": map[string]interface{}{
		"kubernetes_provider_config": map[string]interface{}{
			"host":                   "dummy-host",
			"token":                  "dummy-token",
			"cluster_ca_certificate": "dummy-certificate",
		},
		"cluster_security_group": "dummy-sg",
	},
	"vpc":                     VpcDefaultModuleVariable,
	"db_major_engine_version": "12",
	"db_allocated_storage":    5,
	"db_instance_class":       "dummy_db_instance_class",
	"db_iops":                 1000,
	"db_name":                 "jira",
	"ingress": map[string]interface{}{
		"outputs": map[string]interface{}{
			"r53_zone":        "dummy_r53_zone",
			"domain":          "dummy.domain.com",
			"certificate_arn": "dummy_arn",
			"lb_hostname":     "dummy.hostname.com.au",
			"lb_zone_id":      "dummy_zone_id",
		},
	},
	"replica_count": 1,
	"jira_configuration": map[string]interface{}{
		"helm_version":        "1.0.0",
		"cpu":                 "2",
		"mem":                 "2Gi",
		"min_heap":            "384m",
		"max_heap":            "786m",
		"reserved_code_cache": "512m",
	},
	"db_master_password":     "dummy_password",
	"db_master_username":     "dummy_username",
	"db_snapshot_identifier": "dummy-rds-snapshot-id",
}
