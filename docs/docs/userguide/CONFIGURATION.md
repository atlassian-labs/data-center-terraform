# Configuration

In order to create the infrastructure and install the product you need to configure the terraform project.
All configuration data should go to a terraform variable file.


The config file contents is divided into two groups:

1. [Mandatory configuration](#mandatory-configuration)
2. [Optional configuration](#optional-configuration)


!!! info "Configuration file format."
    The config file is an ascii text file with extension of `.tfvar`.
    The config file should contain all mandatory configuration items with valid value.
    Optional items can be part of the content. If any optional item is missing, the default value will be applied.
   
The mandatory configuration items are those you should define once before the first installation, and you cannot change them in the entire environment lifecycle.

However, the optional configuration part applies to those items that are not required for installation by default, but you can define and override the default value.
The optional configuration may change anytime in the life cycle of the environment.
Terraform will keep the latest status of the environment and use it for any further change you make later.

!!! info "An example of config file for terraform project:"
    Here is a sample of a configuration file for the project.
    ``` terraform
    # Mandatory items
    environment_name = "my-bamboo-env"
    region           = "us-east-2"
   
    # Optional items
    resource_tags = {
      Terraform    : "true",
      Organization : "atlassian",
      product      : "bamboo" ,
    }
   
    instance_types   = ["m5.xlarge"]
    desired_capacity = 2
    domain           = "subdomain.mydomain.com"
    ```

## Mandatory configuration

### Environment Name
`environment_name` provides your environment a unique name within a single cloud provider account.
This value cannot be altered after the configuration has been applied.
The value will be used to form the name of some resources including `vpc` and `Kubernetes cluster`.
syntax:
```
syntax:

    environment_name = "<YOUR-ENVIRONMENT-NAME>"
```
Environment names should start with an alphabet character and could contain alphabet, numbers and dash `-`.
The length of the `environment_name` value cannot exceed 32 characters.


### Region
`region` defines the cloud provider region that this configuration will deploy to.
Since we only support AWS Cloud provider then this value should a valid [AWS region](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html){.external}.


```
syntax:

    region = "<Region>"  # e.g: "ap-northeast-2"
```

## Optional configuration

### Resource Tags
`resource_tags` is the custom tags for all resources to be created in the environment. Tag names should be unique.
You can add all tags you need to propagate among the resources as a list. Resource tags are optional.

```
syntax:

    resource_tags = {
      <tag-name-0> : "<tag-value>",
      <tag-name-1> : "<tag-value>",
      ...
      <tag-name-n> : <tag-value>,
    }
```

### Cluster Instance Type
`instance_types` provides the instance types for the Kubernetes cluster node group.
The default value for this would be `m5.xlarge` if it is not defined in the config file.
Instance type should be a valid [AWS instance type](https://aws.amazon.com/ec2/instance-types/){.external}.

```
syntax:

    instance_types = ["instance-type"]  # e.g: "m5.2xlarge"
```

### Cluster Size
`desired_capacity` provides the desired number of nodes that the node group should launch with initially.
The default value for the number of nodes in Kubernetes node groups is `1`.
Maximum number of `desired_capacity` would be `10` and this number of the nodes cannot be set to less than `1` node.

```
syntax:

    desired_capacity = <number-of-nodes>  # between 1 and 10
```

### Domain Name