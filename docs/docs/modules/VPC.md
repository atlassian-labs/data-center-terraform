# Amazon Virtual Private Cloud (VPC)

VPC is a service that lets you launch AWS resources in a logically isolated 
virtual network that you define. 

!!! info "Find more more detail about the VPC module"
    We use the official Terraform AWS module in this project. Please visit [aws vpc Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to see the detail and more examples about VPC module.
    

### Usage
```hcl-terraform
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dc-infrastructure-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = true

  tags                = {  Terraform = "true" }
  public_subnet_tags  = { <list of public subnet tags> }
  private_subnet_tags = { <list of private subnet tags>}
}

```

## Inputs

### cdir
The CIDR block for the VPC. Default value is a `10.0.0.0/10`, but not acceptable by AWS and should be overridden

### azs
A list of availability zones names or ids in the region

### private_subnets
A list of private subnets inside the VPC

### public_subnets
A list of public subnets inside the VPC	

### enable_nat_gateway
Should be true if you want to provision NAT Gateways for each of your private networks	

### single_nat_gateway
Should be true if you want to provision a single shared NAT Gateway across all of your private networks

### enable_vpn_gateway
Should be true if you want to create a new VPN Gateway resource and attach it to the VPC	

### tags
A map of tags to add to all resources

### public_subnet_tags
Additional tags for the public subnets	

### public_subnet_tags
Additional tags for the public subnets	

## Outputs

### output vpc_id
The ID of the VPC

### private_subnets
List of IDs of private subnets

### private_subnets_cidr_blocks
List of cidr_blocks of private subnets


### public_subnets
List of IDs of public subnets


### public_subnets_cidr_blocks
List of cidr_blocks of public subnets

