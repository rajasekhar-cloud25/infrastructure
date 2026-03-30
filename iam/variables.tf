# ============================================================
# variables.tf — IAM Module
# ============================================================

variable "resource_name" {
  description = "The resource name"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC provider URL from EKS module — with https://"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all IAM resources"
  type        = map(string)
  default     = {}
}

variable "github_repo" {
  description = "GitHub repo in format: username/repo-name"
  type        = string
}