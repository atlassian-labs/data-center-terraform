package unittest

const TestResourceOwner = "terraform_unit_test"

// VPC

var DefaultVpc = map[string]interface{}{
	"vpc_name": "test-vpc",
	"vpc_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
}

var VpcWithCustomisedCidr = map[string]interface{}{
	"vpc_name": "test-vpc",
	"vpc_cidr": "10.0.0.0/20",
	"vpc_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
}

var VpcWithoutName = map[string]interface{}{
	"vpc_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
}

var VpcWithInvalidName = map[string]interface{}{
	"vpc_name": "test-vpc/12",
	"vpc_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
}

var VpcWithInvalidCidr = map[string]interface{}{
	"vpc_name": "test-vpc",
	"vpc_cidr": "10.0.0.0/0",
	"vpc_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
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
	"eks_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
	"ingress_domain":   "test.deplops.com", // needs to be a real domain otherwise this test will fail
}

var EksWithInvalidClusterName = map[string]interface{}{
	"cluster_name": "cluster name with invalid spaces",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"eks_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 1,
	"ingress_domain":   "ingress.domain.com",
}

var EksWithDesiredCapacityOverLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"eks_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
	"instance_types":   []string{"instance_type1", "instance_type2"},
	"desired_capacity": 11,
	"ingress_domain":   "ingress.domain.com",
}

var EksDesiredCapacityUnderLimit = map[string]interface{}{
	"cluster_name": "dummy-cluster-name",
	"vpc_id":       "dummy_vpc_id",
	"subnets":      []string{"subnet1", "subnet2"},
	"eks_tags": map[string]interface{}{
		"resource_owner": TestResourceOwner,
	},
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
