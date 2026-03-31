variable "aws_region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "terraform-eks-demo"
  type    = string
}

variable "vpc_id" {
  type = string
  description = "The ID of the subnet where the AKS cluster will be deployed."
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "resource_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_api_allowed_cidrs" {
  description = "Additional CIDRs allowed to access the cluster API (VPN, office IPs)"
  type        = list(string)
  default     = []
}

# ─── Node Group ───
variable "node_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}


variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster (from IAM module)"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS nodes (from IAM module)"
  type        = string
}

# Policy attachment IDs passed from IAM module for depends_on
variable "cluster_policy_attachments" {
  description = "Cluster IAM policy attachment IDs (ensures policies exist before cluster)"
  type        = list(string)
  default     = []
}

variable "node_policy_attachments" {
  description = "Node IAM policy attachment IDs (ensures policies exist before node group)"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "workstation_cidr" {
  description = "Your workstation IP CIDR for kubectl access (e.g. 203.0.113.5/32). Leave empty to skip."
  type        = string
  default     = ""
}

variable "api_allowed_cidrs" {
  description = "Additional CIDRs allowed to access cluster API (VPN, office)"
  type        = list(string)
  default     = []
}


variable "github_actions_role_arn" {
  description = "GitHub Actions IAM role ARN"
  type        = string
}

variable "admin_iam_user_arn" {
  description = "Admin IAM user ARN for local kubectl access"
  type        = string
  default     = ""
}

