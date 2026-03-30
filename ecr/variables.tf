############################
# Variables
############################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ─── Account Setting ───
variable "basic_scan_type_version" {
  description = "Basic scan type version: AWS_NATIVE or CLAIR"
  type        = string
  default     = "AWS_NATIVE"

  validation {
    condition     = contains(["AWS_NATIVE", "CLAIR"], var.basic_scan_type_version)
    error_message = "Must be AWS_NATIVE or CLAIR."
  }
}

# ─── Registry Scanning ───
variable "scan_type" {
  description = "Registry-level scan type: BASIC or ENHANCED"
  type        = string
  default     = "ENHANCED"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.scan_type)
    error_message = "Must be BASIC or ENHANCED."
  }
}

variable "scanning_rules" {
  description = "List of scanning rules for the registry"
  type = list(object({
    scan_frequency = string
    filter         = string
    filter_type    = string
  }))
  default = [
    {
      scan_frequency = "CONTINUOUS_SCAN"
      filter         = "prod-*"
      filter_type    = "WILDCARD"
    },
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
    }
  ]
}

# ─── Repositories ───
variable "repositories" {
  description = "List of ECR repositories to create"
  type = list(object({
    name                 = string
    image_tag_mutability = optional(string, "IMMUTABLE")
    encryption_type      = optional(string, "AES256")
    kms_key_arn          = optional(string, null)
    force_delete         = optional(bool, false)
    lifecycle_policy     = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = [
    {
      name = "my-app"
    },
    {
      name                 = "my-api"
      image_tag_mutability = "MUTABLE"
    }
  ]
}

# ─── Lifecycle Defaults ───
variable "default_untagged_expiry_days" {
  description = "Days before untagged images expire (default lifecycle)"
  type        = number
  default     = 14
}

variable "default_max_image_count" {
  description = "Max number of tagged images to keep (default lifecycle)"
  type        = number
  default     = 30
}

# ─── Cross-Account Access ───
variable "cross_account_arns" {
  description = "List of AWS account ARNs allowed to pull images"
  type        = list(string)
  default     = []
}

# ─── Registry Policy ───
variable "registry_policy" {
  description = "JSON registry-level policy (optional)"
  type        = string
  default     = null
}

# ─── Replication ───
variable "replication_rules" {
  description = "List of replication rules for cross-region or cross-account replication"
  type = list(object({
    destinations = list(object({
      region      = string
      registry_id = string
    }))
    repository_filters = optional(list(object({
      filter      = string
      filter_type = string
    })), [])
  }))
  default = []
}

# ─── Pull-Through Cache ───
variable "pull_through_cache_rules" {
  description = "Pull-through cache rules for upstream registries"
  type = list(object({
    ecr_repository_prefix = string
    upstream_registry_url = string
  }))
  default = []
}

# ─── Tags ───
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "ecr"
  }
}
