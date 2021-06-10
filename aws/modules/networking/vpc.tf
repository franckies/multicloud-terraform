################################################################################
# VPC, Internet Gateway, Subnets Module
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs = var.azs
  # subnets
  private_subnets = var.private_subnets #backend layer
  intra_subnets   = var.intra_subnets   #frontend layer
  public_subnets  = var.public_subnets  #external lb layer

  enable_vpn_gateway = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  #enable dns resolution support
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}