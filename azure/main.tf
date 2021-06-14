#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.63.0"
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
  #vpc_name              = 
  #vpc_cidr              =
  #azs                   =
  #private_subnets       =
  #public_subnets        =
  #intra_subnets         =
}

module "frontend" {
  source         = "./modules/frontend"
  public_ip_id   = module.networking.public_ip_id
  private_subnet = module.networking.private_subnet
  public_subnet  = module.networking.public_subnet
  intra_subnet   = module.networking.intra_subnet
  #prefix_name   =
  #resource_group= 
  #http_port     =
  #https_port    =
  #ssh_port      = 
  #bastion_user  =
  #bastion_vmsize= 
  #vm_username   =
  #vm_password   = 
  #os_config     = 

}