output "vpc_id"  {
  value = aws_vpc.main.id
}

output "vpc_cidr"         {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ips" {
  description = "Elastic IPs attached to NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "availability_zone"{
  value = var.availability_zones
}
