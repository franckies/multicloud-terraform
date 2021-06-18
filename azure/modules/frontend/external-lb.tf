resource "azurerm_lb" "frontend" {
  name                = "${var.prefix_name}-lb"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
  frontend_ip_configuration {
    name                 = "${var.prefix_name}-PublicIPAddress"
    public_ip_address_id = var.public_ip_id
  }
  sku = "Standard"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_lb_backend_address_pool" "frontend" {
  #resource_group_name = var.resource_group.name
  loadbalancer_id = azurerm_lb.frontend.id
  name            = "${var.prefix_name}-BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "frontend" {
  resource_group_name            = var.resource_group.name
  name                           = "http"
  loadbalancer_id                = azurerm_lb.frontend.id
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 89
  backend_port                   = var.http_port
  frontend_ip_configuration_name = "${var.prefix_name}-PublicIPAddress"
}

resource "azurerm_lb_probe" "frontend" {
  resource_group_name = var.resource_group.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/health"
  port                = var.http_port
}

# Allowing VMs within scale set to go to internet
resource "azurerm_lb_outbound_rule" "frontend" {
  resource_group_name     = var.resource_group.name
  loadbalancer_id         = azurerm_lb.frontend.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id

  frontend_ip_configuration {
    name = "${var.prefix_name}-PublicIPAddress"
  }
}
