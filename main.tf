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
module "aws_infra" {
  source = "./aws/"

}

module "azure_infra" {
  source = "./azure/"


  aws_api_ep = module.aws_infra.api_gateway_url
}

resource "azurerm_traffic_manager_profile" "counter-app" {
  name                = "counter-app-multicloud"
  resource_group_name = "cloud-semeraro-tesina"

  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "counter-app-multicloud"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_traffic_manager_endpoint" "counter-app-azyre" {
  name                = "counter-app-multicloud"
  resource_group_name = "cloud-semeraro-tesina"
  profile_name        = azurerm_traffic_manager_profile.counter-app.name
  target              = module.azure_infra.load_balancer_dns
  type                = "externalEndpoints"
  weight              = 100
}

resource "azurerm_traffic_manager_endpoint" "counter-app-aws" {
  name                = "counter-app-multicloud"
  resource_group_name = "cloud-semeraro-tesina"
  profile_name        = azurerm_traffic_manager_profile.counter-app.name
  target              = module.aws_infra.load_balancer_dns
  type                = "externalEndpoints"
  weight              = 100
}
