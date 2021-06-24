multicloud  = true
prefix_name = "counter-app"
http_port   = 80
https_port  = 443
ssh_port    = 22
#============================= AZURE VARS ======================================
resource_group = {
  "name" = "cloud-semeraro-tesina"
  region = "westeurope"
}
vnet_cidr      = "192.168.0.0/16"
private_subnet = ["192.168.2.0/24"]
intra_subnet   = ["192.168.1.0/24"]
public_subnet  = ["192.168.0.0/24"]
bastion_user   = "bastion"
bastion_vmsize = "Standard_DS1_v2"
vm_username    = "azureuser"
vm_password    = "Password1234!"
os_config = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
  version   = "latest"
}
instances_num        = 2
ssh_private_key_path = "~/.ssh/id_rsa.pub"

#============================= AWS VARS ========================================
vpc_cidr         = "192.168.0.0/16"
azs              = ["eu-west-1a", "eu-west-1b"]
private_subnets  = ["192.168.2.0/24", "192.168.3.0/24"]
intra_subnets    = ["192.168.4.0/24", "192.168.5.0/24"]
public_subnets   = ["192.168.0.0/24", "192.168.1.0/24"]
stage_name       = "dev"
ami              = "ami-038d7b856fe7557b3"
vm_instance_type = "t2.small"
asg_min_size     = 1
asg_max_size     = 8