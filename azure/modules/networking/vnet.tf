module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = var.resource_group_name
  vnet_location       = var.region
  address_space       = [var.vnet_cidr]
  subnet_prefixes     = concat(var.public_subnets, var.private_subnets, var.intra_subnets, )
  subnet_names        = ["public_subnet", "private_subnet", "intra_subnet"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "azurerm_public_ip" "counter-app-public-ip" {
  name                = "counter-app-public-ip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.resource_group_name
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}