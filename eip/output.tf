output "nlb_eip_allocation_ids" {
  value = aws_eip.nlb[*].id
}

output "nlb_eip_public_ips" {
  value = aws_eip.nlb[*].public_ip
}