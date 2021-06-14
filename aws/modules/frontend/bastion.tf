################################################################################
# Bastion
################################################################################
module "bastion" {
  source  = "umotif-public/bastion/aws"
  version = "~> 2.1.0"

  name_prefix    = var.prefix_name
  ami_id         = var.ami
  vpc_id         = var.vpc_id
  public_subnets = var.public_subnets

  ssh_key_name = module.key_pair.key_pair_key_name

  bastion_instance_types = [var.vm_instance_type]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}