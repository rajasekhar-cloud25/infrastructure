variable "nlb_eip_allocation_ids" {
  type        = list(string)
  description = "EIP allocation IDs for NLB"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "cluster_ca_certificate" {
  type        = string
  description = "EKS cluster CA certificate"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
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