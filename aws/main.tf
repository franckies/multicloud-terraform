#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    aws = {
      source             = "hashicorp/aws"
      version            = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                 = "eu-west-1"
}

#============================= MODULES IMPORT ==================================
module "networking" {
  source                 = "./modules/networking"
  #vpc_name              = 
  #vpc_cidr              =
  #azs                   =
  #private_subnets       =
  #public_subnets        =
  #intra_subnets         =
  frontend_sg_id         = module.frontend.frontend_sg
}

module "data" {
  source                = "./modules/data"
}

module "frontend" {
  source                = "./modules/frontend"

  vpc_id                = module.networking.vpc_id
  private_subnets       = module.networking.private_subnets
  public_subnets        = module.networking.public_subnets
  intra_subnets         = module.networking.intra_subnets  

  apigw_url             = module.backend.api_url
  #prefix_name          =
  #http_port            = 
  #https_port           =
  #ssh_port             =
  #ami                  =
  #vm_instance_type     =

  #asg_min_size         = 
  #asg_max_size         = 
}

module "backend" {
  source                = "./modules/backend"

  vpc_id                = module.networking.vpc_id
  private_subnets       = module.networking.private_subnets
  public_subnets        = module.networking.public_subnets
  intra_subnets         = module.networking.intra_subnets  

  dynamo_table_arn      = module.data.table_arn

  vpc_endpoint_id       = module.networking.vpc_endpoint_id
}

output "api_gateway_url" {
  value = module.backend.api_url
}
output "load_balancer_url" {
  value = module.frontend.lb_dns
}