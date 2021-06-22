################################################################################
# Network security group for scale set
################################################################################
resource "azurerm_network_security_group" "frontend" {
  name                = "${var.prefix_name}-frontend-sg"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
}

resource "azurerm_network_security_rule" "http_access" {
  name                        = "allow-internet-port-80"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 200
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = var.http_port
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_network_security_rule" "ssh_access_frombastion" {
  name                        = "allow-bastion-ssh"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 210
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = azurerm_network_interface.bastion.private_ip_address
  destination_port_range      = var.ssh_port
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = var.private_subnet
  network_security_group_id = azurerm_network_security_group.frontend.id
}

################################################################################
# Scale set
################################################################################
resource "azurerm_linux_virtual_machine_scale_set" "frontend" {
  name                = "${var.prefix_name}-frontend-ss"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name

  custom_data = base64encode(templatefile("${path.module}/user-data.sh.tpl", { apiname = "${var.api_url}" }))

  computer_name_prefix = var.prefix_name

  zones = ["1", "2"]

  sku            = "Standard_F2"
  instances      = 1
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${var.ssh_private_key_path}")
  }

  source_image_reference {
    publisher = var.os_config.publisher
    offer     = var.os_config.offer
    sku       = var.os_config.sku
    version   = var.os_config.version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "${var.prefix_name}-ipconfig"
      primary                                = true
      subnet_id                              = var.private_subnet
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.frontend.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.frontend.id]
    }
  }
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}