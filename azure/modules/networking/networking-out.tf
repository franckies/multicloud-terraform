output "public_ip_id" {
  description = "The public IP id."
  value       = azurerm_public_ip.frontend.id
}

output "public_ip_dns" {
  description = "The dns A record associated with the frontend public IP."
  value       = azurerm_public_ip.frontend.fqdn
}

output "public_ip_url" {
  description = "The dns A record associated with the frontend public IP."
  value       = "http://${azurerm_public_ip.frontend.fqdn}"
}

output "public_subnet" {
  description = "The public subnets ids."
  value       = azurerm_subnet.public.id
}

output "private_subnet" {
  description = "The private subnets ids."
  value       = azurerm_subnet.private.id
}

output "intra_subnet" {
  description = "The intra subnets ids."
  value       = azurerm_subnet.intra.id
}
