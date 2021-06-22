#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

#============================= MODULES IMPORT ==================================
module "networking" {
  source = "./modules/networking"

  prefix_name     = var.prefix_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets
}

module "data" {
  source = "./modules/data"

  prefix_name = var.prefix_name
}

module "frontend" {
  source = "./modules/frontend"

  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  public_subnets  = module.networking.public_subnets
  intra_subnets   = module.networking.intra_subnets
  apigw_url       = module.backend.base_url

  prefix_name      = var.prefix_name
  http_port        = var.http_port
  https_port       = var.https_port
  ssh_port         = var.ssh_port
  ami              = var.ami
  vm_instance_type = var.vm_instance_type
  asg_min_size     = var.asg_min_size
  asg_max_size     = var.asg_max_size


}

module "backend" {
  source = "./modules/backend"

  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  public_subnets  = module.networking.public_subnets
  intra_subnets   = module.networking.intra_subnets

  dynamo_table_arn = module.data.table_arn

  ##############################################################################
  # API url for azure api management to implement the multicloud infrastructure. 
  # By default it is an empty string, resulting in the deploy of the aws
  # infrastructure alone.
  ##############################################################################
  azure_api_url = var.azure_api_url

  prefix_name = var.prefix_name
  stage_name  = var.stage_name
  http_port   = var.http_port
  https_port  = var.https_port
}

#================================= OUTPUT ======================================
output "api_gateway_url" {
  value = module.backend.base_url
}
output "load_balancer_url" {
  value = module.frontend.lb_url
}
output "load_balancer_dns" {
  value = module.frontend.lb_dns
}