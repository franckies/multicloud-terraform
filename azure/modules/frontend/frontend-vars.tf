variable "prefix_name" {
  type        = string
  default     = "counter-app"
  description = "Prefix name for application layer."
}

variable "resource_group" {
  type = map(any)
  default = {
    name   = "cloud-semeraro-tesina"
    region = "westeurope"
  }
  description = "Resource group name and region."
}

variable "http_port" {
  type        = number
  default     = 80
  description = "The http port."
}

variable "https_port" {
  type        = number
  default     = 443
  description = "The http port."
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "The ssh port."
}

variable "bastion_user" {
  type        = string
  default     = "bastion"
  description = "Hostname for bastion vm."
}

variable "bastion_vmsize" {
  type        = string
  default     = "Standard_DS1_v2"
  description = "Size of bastion host."
}

variable "vm_username" {
  type        = string
  default     = "azureuser"
  description = "Username for vms."
}

variable "vm_password" {
  type        = string
  default     = "Password1234!"
  description = "Password for vms."
}

variable "os_config" {
  type = map(any)
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  description = "Configuration of OS for bastion and vms."
}

variable "public_ip_id" {
  description = "ID of public IP resource."
}

variable "public_subnet" {
  description = "The public subnet id."
}

variable "intra_subnet" {
  description = "The intra subnet id."
}

variable "private_subnet" {
  description = "The private subnet id."
}