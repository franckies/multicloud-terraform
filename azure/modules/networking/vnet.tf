module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = var.resource_group.name
  vnet_location       = var.resource_group.region
  address_space       = [var.vnet_cidr]
  subnet_prefixes     = concat(var.public_subnets, var.private_subnets, var.intra_subnets, )
  subnet_names        = ["public_subnet", "private_subnet", "intra_subnet"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
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