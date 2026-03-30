# ============================================================
# environments/dev/outputs.tf
# ============================================================

# ── EKS ───
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubectl_config_command" {
  description = "Run this to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# ── IAM (base) ───
output "github_actions_role_arn" {
  description = "Add this to GitHub repo secrets as AWS_ROLE_ARN"
  value       = module.iam.github_actions_role_arn
}

# ── VPC ───
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_controller_role_arn" {
  value = module.iam.alb_controller_role_arn
}

output "cluster_autoscaler_role_arn" {
  value = module.iam.cluster_autoscaler_role_arn
}

output "ebs_csi_driver_role_arn" {
  value = module.iam.ebs_csi_driver_role_arn
}

output "external_secrets_role_arn" {
  value = module.iam.external_secrets_role_arn
}