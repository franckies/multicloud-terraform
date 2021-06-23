#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.63.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "=1.5.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}
#============================= MODULES IMPORT ==================================
module "networking" {
  source = "./modules/networking"

  resource_group = var.resource_group
  prefix_name    = var.prefix_name
  vnet_cidr      = var.vnet_cidr
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
  intra_subnet   = var.intra_subnet
}

module "data" {
  source       = "./modules/data"
  intra_subnet = module.networking.intra_subnet

  resource_group = var.resource_group
  prefix_name    = var.prefix_name
}

module "frontend" {
  source = "./modules/frontend"

  public_ip_id   = module.networking.public_ip_id
  private_subnet = module.networking.private_subnet
  public_subnet  = module.networking.public_subnet
  intra_subnet   = module.networking.intra_subnet
  api_url        = module.backend.api_url

  resource_group       = var.resource_group
  prefix_name          = var.prefix_name
  http_port            = var.http_port
  https_port           = var.https_port
  ssh_port             = var.ssh_port
  bastion_user         = var.bastion_user
  bastion_vmsize       = var.bastion_vmsize
  instances_num        = var.instances_num
  vm_username          = var.vm_username
  vm_password          = var.vm_password
  os_config            = var.os_config
  ssh_private_key_path = var.ssh_private_key_path
}

module "backend" {
  source = "./modules/backend"

  connection_string = module.data.connection_string
  intra_subnet      = module.networking.intra_subnet

  ##############################################################################
  # API url for aws api gateway to implement the multicloud infrastructure. 
  # By default it is an empty string, resulting in the deploy of the azure 
  # infrastructure alone.
  ##############################################################################
  aws_api_url = var.aws_api_url

  resource_group = var.resource_group
  prefix_name    = var.prefix_name
  http_port      = var.http_port
  https_port     = var.https_port
}

#================================= OUTPUT ======================================
output "api_management_url" {
  value = module.backend.api_url
}

output "load_balancer_url" {
  value = module.networking.public_ip_url
}

output "load_balancer_dns" {
  value = module.networking.public_ip_dns
}
