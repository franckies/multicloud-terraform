output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC."
  value       = module.vpc.name
}

output "public_subnets" {
  description = "The public subnets ids."
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnets ids."
  value       = module.vpc.private_subnets
}

output "intra_subnets" {
  description = "The intra subnets ids."
  value       = module.vpc.intra_subnets
}

output "vpc_endpoint_id" {
  description = "The VPC endpoint id for api gw communication."
  value       = aws_vpc_endpoint.apigw-endpoint.id
}
