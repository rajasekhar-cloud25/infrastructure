variable "nlb_eip_allocation_ids" {
  type        = list(string)
  description = "EIP allocation IDs for NLB"
}

variable "dns_names" {
  description = "List of DNS subdomains to create"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for NLB"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}