################################################################################
# VPC, Internet Gateway, Subnets Module
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix_name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs
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

# Route table for multicloud communication
resource "aws_route" "r" {
  route_table_id            = module.vpc.intra_route_table_ids[0]
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = module.vpc.natgw_ids[0]
  depends_on                = [module.vpc]
}

################################################################################
# VPC endpoint for private traffic to dynamodb
################################################################################
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.intra_subnets

  endpoints = {
    dynamodb = {
      # gateway endpoint
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids])
      tags = {
        Terraform   = "true"
        Environment = "dev"
        Name        = "dynamodb-vpc-endpoint"
      }
    }
  }
}
