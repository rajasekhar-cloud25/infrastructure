# ============================================================
# environments/dev/outputs.tf
# ============================================================

# ── ECR ───
output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

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

# ── IAM (IRSA) ───
output "alb_controller_role_arn" {
  description = "ALB controller — add to Helm serviceAccount annotation"
  value       = module.iam_irsa.alb_controller_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "Cluster autoscaler — add to Helm serviceAccount annotation"
  value       = module.iam_irsa.cluster_autoscaler_role_arn
}

output "ebs_csi_driver_role_arn" {
  description = "EBS CSI driver — used by EKS addon"
  value       = module.iam_irsa.ebs_csi_driver_role_arn
}

output "external_secrets_role_arn" {
  description = "External secrets — add to Helm serviceAccount annotation"
  value       = module.iam_irsa.external_secrets_role_arn
}

# ── VPC ───
output "vpc_id" {
  value = module.vpc.vpc_id
}
