variable "aws_api_url" {
  type        = string
  description = "Endpoint of aws api gateway for multicloud infrastructure."
  default     = ""
}

variable "prefix_name" {
  type        = string
  default     = "counter-app"
  description = "Prefix name for resources."
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

variable "resource_group" {
  type = map(any)
  default = {
    name   = "cloud-semeraro-tesina"
    region = "westeurope"
  }
  description = "Resource group name and region."
}

variable "vnet_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR of the VPC."
}

variable "private_subnet" {
  type        = list(string)
  default     = ["192.168.2.0/24"]
  description = "Private subnet CIDR where the front end layer will be deployed."
}

variable "intra_subnet" {
  type        = list(string)
  default     = ["192.168.1.0/24"]
  description = "Intra subnet CIDR where the lambda function will be deployed."
}

variable "public_subnet" {
  type        = list(string)
  default     = ["192.168.0.0/24"]
  description = "Public subnet CIDR where the bastion and application load balancer will be deployed."
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

variable "instances_num" {
  type        = number
  default     = "2"
  description = "Number of instances in the scale set."
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

variable "ssh_private_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to your private key."
}