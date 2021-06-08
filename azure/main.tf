#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    aws = {
      source             = "hashicorp/azurerm"
      version            = "~>2.0"
    }
  }
}

# Configure the AWS Provider
provider "azurerm" {
  features                 = {}
}

#============================= MODULES IMPORT ==================================
