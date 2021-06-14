output "public_ip_id" {
  description = "The public IP id."
  value       = azurerm_public_ip.frontend.id
}

output "public_subnet" {
  description = "The public subnets ids."
  value       = module.vnet.vnet_subnets[0]
}

output "private_subnet" {
  description = "The private subnets ids."
  value       = module.vnet.vnet_subnets[1]
}

output "intra_subnet" {
  description = "The intra subnets ids."
  value       = module.vnet.vnet_subnets[2]
}
