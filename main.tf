#============================= PROVIDER CONFIG =================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.63.0"
    }
  }
  # backend "http" {
  #   address = "value"
  #   method  = "PUT"
  # }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

#============================= MODULES IMPORT ==================================
module "azure_infra" {
  source      = "./azure/"
  aws_api_url = var.multicloud == true ? module.aws_infra.api_gateway_url : ""

  resource_group = var.resource_group
  prefix_name    = var.prefix_name

  # Networking vars
  vnet_cidr      = var.vnet_cidr
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
  intra_subnet   = var.intra_subnet

  # Frontend vars
  http_port            = var.http_port
  https_port           = var.https_port
  ssh_port             = var.ssh_port
  bastion_user         = var.bastion_user
  bastion_vmsize       = var.bastion_vmsize
  vm_username          = var.vm_username
  vm_password          = var.vm_password
  os_config            = var.os_config
  ssh_private_key_path = var.ssh_private_key_path
}

module "aws_infra" {
  source        = "./aws/"
  azure_api_url =   var.multicloud == true ? module.azure_infra.api_management_url : ""
  prefix_name   = var.prefix_name

  # Networking vars
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

  # Frontend vars
  http_port        = var.http_port
  https_port       = var.https_port
  ssh_port         = var.ssh_port
  ami              = var.ami
  vm_instance_type = var.vm_instance_type
  asg_min_size     = var.asg_min_size
  asg_max_size     = var.asg_max_size

  # Backend vars
  stage_name = var.stage_name
}


#============================= TRAFFIC MANAGER =================================
resource "azurerm_traffic_manager_profile" "counter-app" {
  count = var.multicloud == true ? 1 : 0
  name                = "${var.prefix_name}-multicloud"
  resource_group_name = var.resource_group.name

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

resource "azurerm_traffic_manager_endpoint" "counter-app-azure" {
  count = var.multicloud == true ? 1 : 0
  name                = "${var.prefix_name}-azure"
  resource_group_name = var.resource_group.name
  profile_name        = azurerm_traffic_manager_profile.counter-app[count.index].name
  target              = module.azure_infra.load_balancer_dns
  type                = "externalEndpoints"
  weight            = 100
}

resource "azurerm_traffic_manager_endpoint" "counter-app-aws" {
  count = var.multicloud == true ? 1 : 0
  name                = "${var.prefix_name}-aws"
  resource_group_name = var.resource_group.name
  profile_name        = azurerm_traffic_manager_profile.counter-app[count.index].name
  target              = module.aws_infra.load_balancer_dns
  type                = "externalEndpoints"
  weight            = 100
}

output "dns_name" {
  value = var.multicloud == true ? "http://${azurerm_traffic_manager_profile.counter-app[0].fqdn}" : ""
}
output "aws_dns" {
  value = module.aws_infra.load_balancer_url
}
output "azure_dns" {
  value = module.azure_infra.load_balancer_url
}