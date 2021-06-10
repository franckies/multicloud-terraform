output "bastion_sg" {
  description = "The security group id of the bastion"
  value       = module.bastion.security_group_id
}

output "lb_dns" {
  description = "The DNS name of the external load balancer"
  value       = "https://${aws_alb.counter-app-eloadbalancer.dns_name}"
}
