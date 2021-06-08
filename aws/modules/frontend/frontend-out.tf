output "bastion_sg" {
  description = "The security group id of the bastion"
  value       = module.bastion.security_group_id
}