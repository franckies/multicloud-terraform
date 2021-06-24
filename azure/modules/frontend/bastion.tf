################################################################################
# Public IP for bastion
################################################################################
resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix_name}-bastion-ip"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
  domain_name_label   = "${var.prefix_name}-ssh"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

################################################################################
# Network security group for bastion
################################################################################
resource "azurerm_network_security_group" "bastion" {
  name                = "${var.prefix_name}-bastion-sg"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name
}

resource "azurerm_network_security_rule" "ssh_access" {
  name                        = "ssh-access-rule"
  network_security_group_name = azurerm_network_security_group.bastion.name
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 200
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = azurerm_network_interface.bastion.private_ip_address
  destination_port_range      = var.ssh_port
  protocol                    = "TCP"
  resource_group_name         = var.resource_group.name
}

# We attach the NSG to the bastion NIC
resource "azurerm_network_interface" "bastion" {
  name                = "${var.prefix_name}-bastion-nic"
  location            = var.resource_group.region
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = var.public_subnet
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}


################################################################################
# Bastion VM
################################################################################
resource "azurerm_virtual_machine" "bastion" {
  # Solves the problem of misconfigured dependencies (https://github.com/terraform-providers/terraform-provider-azurerm/issues/6669)
  depends_on = [
    azurerm_network_interface_security_group_association.bastion
  ]
  name                          = "${var.prefix_name}-bastion"
  location                      = var.resource_group.region
  resource_group_name           = var.resource_group.name
  network_interface_ids         = [azurerm_network_interface.bastion.id]
  vm_size                       = var.bastion_vmsize
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.os_config.publisher
    offer     = var.os_config.offer
    sku       = var.os_config.sku
    version   = var.os_config.version
  }

  storage_os_disk {
    name              = "bastion-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.bastion_user
    admin_username = var.vm_username
    admin_password = var.vm_password
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
