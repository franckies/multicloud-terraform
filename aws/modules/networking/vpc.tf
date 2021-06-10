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

# VPC endpoint for API Gateway
resource "aws_security_group" "vpc-endpoint-sg" {
  name = "vpc-endpoint-sg"

  description = "Allow HTTP, HTTPS from frontend servers"
  vpc_id      = module.vpc.vpc_id

  # Inbound connections from frontend servers
  ingress {
    from_port        = var.http_port
    to_port          = var.http_port
    protocol         = "tcp"
    security_groups = [var.frontend_sg_id]
  }
  
  ingress {
    from_port        = var.https_port
    to_port          = var.https_port
    protocol         = "tcp"
    security_groups = [var.frontend_sg_id]
  }

  # All outbound connections on HTTP and HTTPs
  egress {
    from_port = var.http_port
    to_port   = var.http_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = var.https_port
    to_port   = var.https_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc_endpoint_service" "apigw-endpoint-svc" {
  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw-endpoint" {
  vpc_id              = module.vpc.vpc_id
  service_name        = data.aws_vpc_endpoint_service.apigw-endpoint-svc.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpc-endpoint-sg.id]
}