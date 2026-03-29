output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "IDs of the public route tables."
  value       = module.vpc.public_route_table_ids
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT gateway."
  value       = one(module.vpc.nat_public_ips)
}

output "availability_zones" {
  description = "Availability zones used by the VPC."
  value       = module.vpc.azs
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group attached to VPC interface endpoints."
  value       = try(aws_security_group.vpc_endpoints[0].id, null)
}
