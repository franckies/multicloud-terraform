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

provider "azuread" {
}


#============================= MODULES IMPORT ==================================
module "networking" {
  source = "./modules/networking"
  #resource_group        =

  # prefix_name          =
  # vpc_cidr             =
  # private_subnets      =
  # public_subnets       = 
  # intra_subnets        =
}

module "frontend" {
  source = "./modules/frontend"
  # resource_group =

  public_ip_id     = module.networking.public_ip_id
  private_subnet   = module.networking.private_subnet
  public_subnet    = module.networking.public_subnet
  intra_subnet     = module.networking.intra_subnet
  api_url          = module.backend.api_url

  # prefix_name    =
  # http_port      =
  # https_port     =
  # ssh_port       = 
  # bastion_user   =
  # bastion_vmsize = 
  # vm_username    =
  # vm_password    = 
  # os_config      = 

}

module "backend" {
  source = "./modules/backend"
  # resource_group  =

  connection_string = module.data.connection_string
  intra_subnet      = module.networking.intra_subnet

  # prefix_name     =
  # http_port       =
  # https_port      =
}

module "data" {
  source = "./modules/data"
  # resource_group =

  intra_subnet     = module.networking.intra_subnet

  # prefix_aname   =
}

output "api_url" {
  value = module.backend.api_url
}

output "lb_url" {
  value = "http://${module.networking.public_ip_dns}"
}
