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

domain_name = "rajasekharcloud.com"

# ============================================================
# environments/dev/terraform.tfvars
# ============================================================

aws_region    = "us-east-1"
github_repo   = "rajasekhar-cloud25/infrastructure"
admin_iam_user_arn = "arn:aws:iam::008469331115:user/raj-admin"

nlb_eip_allocation_ids = [
  "eipalloc-09595a182e792f01f",
  "eipalloc-032c83197c359b3fe"
]

# VPC (2 AZs for cost saving)
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
single_nat_gateway   = true

# EKS (cost-optimized for demo)
cluster_version     = "1.35"
node_instance_types = ["t3.small"]
node_capacity_type  = "SPOT"
node_desired_size   = 5
node_max_size       = 5
node_min_size       = 2
node_disk_size      = 20

tags = {
  Project     = "ecommerce-k8s-demo"
  Environment = "dev"
  ManagedBy   = "Terraform"
}

