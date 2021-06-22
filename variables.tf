variable "multicloud" {
  type = bool
  default = true
  description = "Whether or not to enable the multicloud infrastructure."
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

# Azure
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

# Aws
variable "stage_name" {
  type        = string
  default     = "dev"
  description = "The stage name of the endpoint."
}

variable "ami" {
  type        = string
  default     = "ami-038d7b856fe7557b3"
  description = "The AMI to build up the VMs, default is ubuntu 16.04."
}

variable "vm_instance_type" {
  type        = string
  default     = "t2.small"
  description = "The VMs type within the AutoScalingGroup."
}

variable "asg_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of VMs within the ASG."
}

variable "asg_max_size" {
  type        = number
  default     = 8
  description = "Maximum number of VMs within the ASG."
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR of the VPC."
}

variable "azs" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
  description = "The Availability zones in which the infra will be deployed."
}

variable "private_subnets" {
  type        = list(string)
  default     = ["192.168.2.0/24", "192.168.3.0/24"]
  description = "Private subnets CIDR (one per az), where the front end layer will be deployed."
}

variable "intra_subnets" {
  type        = list(string)
  default     = ["192.168.4.0/24", "192.168.5.0/24"]
  description = "Intra subnets CIDR (one per az), where the lambda function will be deployed."
}

variable "public_subnets" {
  type        = list(string)
  default     = ["192.168.0.0/24", "192.168.1.0/24"]
  description = "Public subnets CIDR (one per az), where the bastion and application load balancer will be deployed."
}