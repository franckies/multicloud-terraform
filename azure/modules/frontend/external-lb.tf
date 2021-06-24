################################################################################
# External load balancer
################################################################################
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

# Backend pool for scale set.
resource "azurerm_lb_backend_address_pool" "frontend" {
  loadbalancer_id = azurerm_lb.frontend.id
  name            = "${var.prefix_name}-BackEndAddressPool"
}

resource "azurerm_lb_rule" "frontend" {
  resource_group_name            = var.resource_group.name
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "${var.prefix_name}-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.frontend.id
  frontend_ip_configuration_name = "${var.prefix_name}-PublicIPAddress"
  probe_id                       = azurerm_lb_probe.frontend.id
  # Allow outbound connectivity with snat (not suggested for production env., instead, deploy a NAT gateway)
  disable_outbound_snat          = false
}

resource "azurerm_lb_probe" "frontend" {
  resource_group_name = var.resource_group.name
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = var.http_port
}