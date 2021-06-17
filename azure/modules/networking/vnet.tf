# module "vnet" {
#   source              = "Azure/vnet/azurerm"
#   resource_group_name = var.resource_group.name
#   vnet_location       = var.resource_group.region
#   address_space       = [var.vnet_cidr]
#   subnet_prefixes     = concat(var.public_subnets, var.private_subnets, var.intra_subnets, )
#   subnet_names        = ["public_subnet", "private_subnet", "intra_subnet"]

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

resource "azurerm_virtual_network" "networking" {
  name                = "${var.prefix_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.networking.name
  address_prefixes     = var.public_subnets
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.networking.name
  address_prefixes     = var.private_subnets
}

resource "azurerm_subnet" "intra" {
  name                 = "intra-subnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.networking.name
  address_prefixes     = var.intra_subnets
  # delegation {
  #   name = "functionapp-delegation"

  #   service_delegation {
  #     name    = "Microsoft.Web/serverFarms"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
  #   }
  # }
}

resource "azurerm_public_ip" "frontend" {
  name                = "counter-app-public-ip"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  domain_name_label   = var.resource_group.name
  sku = "Standard"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}