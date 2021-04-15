#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

#############################################################################
#############################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"
  # insert the 15 required variables here
  name = "terraform-eks-imply"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a","${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = false
  #ec2_endpoint_policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = [module.imply_service_sg.this_security_group_id]

  create_database_subnet_group = true

  tags = {
    Terraform = "true"
    Environment = "dev"

  }

  vpc_tags = {
      Name = "terraform-eks-imply-node"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }

    public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "imply_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "imply-terraform"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.0.0.0/16"]
  ingress_rules            = ["https-443-tcp","http-80-tcp","mysql-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9095
      to_port     = 9097
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
  ]
}
