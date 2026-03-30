variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_repo" {
  description = "GitHub repo (format: username/repo-name)"
  type        = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "workstation_cidr" {
  description = "Your IP for kubectl access (e.g. 203.0.113.5/32). Leave empty to skip."
  type        = string
  default     = ""
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_disk_size" {
  type    = number
  default = 20
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from EKS cluster"
  type        = string
}

variable "project_name" {
  type = string
}

variable "dns_zone_name" {
  type        = string
  default     = "rajasekharcloud.com"
  description = "The DNS zone name for creating records."
}

variable "namespaces" {
  type = list(string)
  description = "List of Kubernetes namespaces to create"
  default = []  # Default as empty list if not provided
}

variable "primary_name" {
  description = "The environment name, e.g., 'test', 'production'"
  type        = string
}


variable "shared_environments" {
  description = "List of environments"
  type = list(string)
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

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "extra_helm_set_values" {
  type = map(string)
  default = {}
  description = "Additional Helm set values for the MQTT ingress module"
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
