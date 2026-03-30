module "vpc" {
  source               = "../vpc"
  resource_name        = var.primary_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  tags                 = var.tags
}

module "iam" {
  source = "../iam"
  resource_name = var.primary_name
  github_repo   = var.github_repo
  tags =  var.tags

  oidc_issuer_url = module.eks.oidc_issuer_url
}

module "eks" {
  source             = "../eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # IAM roles from base IAM module
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  # Ensure IAM policies are attached before cluster/nodes are created
  cluster_policy_attachments = module.iam.cluster_policy_attachments
  node_policy_attachments    = module.iam.node_policy_attachments

  # Cluster config
  cluster_version         = var.cluster_version
  endpoint_private_access = true
  endpoint_public_access  = true
  workstation_cidr        = var.workstation_cidr

  # Node group (cost-optimized for demo)
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size
  node_disk_size      = var.node_disk_size
  resource_name       = var.primary_name
}

module "kubernetes_ingress" {
  source = "../kubernetes-ingress"
  nlb_eip_allocation_ids  = module.vpc.nlb_eip_allocation_ids
  depends_on              = [module.eks, module.namespaces]
  domain_name             = var.domain_name
  dns_names               = var.dns_names
}

module "namespaces" {
  source     = "../k8s_namespaces"
  namespaces = var.namespaces

  depends_on = [module.eks]
}

module "argocd_deployment" {
  source               = "../argocd_deployment"
  depends_on = [module.eks, module.namespaces]
}
