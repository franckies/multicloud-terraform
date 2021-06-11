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
  source                 = "./modules/networking"
  #vpc_name              = 
  #vpc_cidr              =
  #azs                   =
  #private_subnets       =
  #public_subnets        =
  #intra_subnets         =
}