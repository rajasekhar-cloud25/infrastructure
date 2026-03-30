#########################################################################################
# CLUSTER IDENTITY
#########################################################################################

cluster_name = "EksDemo"

# Only lowercase alphanumeric characters allowed (Azure Storage Account naming rules)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#name-1
# NOTE: A Key Vault will be created with name: "primary_name-KV"
primary_name = "eks-commerce-demo"

# Namespaces to be created
namespaces = [
  "monitoring",
  "argocd",
  "external-secrets",
  "kubecost",
  "cert-manager",
  "shared-os",
  "eks-demo"
]

#########################################################################################
# DOMAINS / DNS
#########################################################################################

dns_names = [
  "argocd",
  "eks-demo"
]

# ============================================================
# environments/dev/terraform.tfvars
# ============================================================

aws_region    = "us-east-1"
github_repo   = "rajasekhar-cloud25/infrastructure"

# VPC (2 AZs for cost saving)
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
single_nat_gateway   = true

# EKS (cost-optimized for demo)
cluster_version     = "1.31"
workstation_cidr    = ""  # Set your IP: "203.0.113.5/32"
node_instance_types = ["t3.small"]
node_capacity_type  = "SPOT"
node_desired_size   = 1
node_max_size       = 2
node_min_size       = 1
node_disk_size      = 20

