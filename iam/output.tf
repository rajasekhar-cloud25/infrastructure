# Output — copy this ARN to GitHub secrets as AWS_ROLE_ARN
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

# ============================================================
# outputs.tf — IAM Module
# All role ARNs exported for use in other modules
# ============================================================

# ── EKS Roles ─────────────────────────────────────────────────
output "eks_cluster_role_arn" {
  description = "EKS cluster role ARN — pass to aws_eks_cluster resource"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "EKS node role ARN — pass to aws_eks_node_group resource"
  value       = aws_iam_role.eks_node.arn
}

# ── IRSA Roles ────────────────────────────────────────────────
output "alb_controller_role_arn" {
  description = "ALB controller IRSA role ARN — add to Helm serviceAccount annotation"
  value       = aws_iam_role.alb_controller.arn
}

output "cluster_autoscaler_role_arn" {
  description = "Cluster autoscaler IRSA role ARN — add to Helm serviceAccount annotation"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "ebs_csi_driver_role_arn" {
  description = "EBS CSI driver IRSA role ARN — add to EKS addon service account"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "external_secrets_role_arn" {
  description = "External secrets IRSA role ARN — reads from AWS SSM"
  value       = aws_iam_role.external_secrets.arn
}


output "cluster_policy_attachments" {
  value = [
    aws_iam_role_policy_attachment.eks_cluster_policy.id,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller.id
  ]
}

output "node_policy_attachments" {
  value = [
    aws_iam_role_policy_attachment.eks_worker_node_policy.id,
    aws_iam_role_policy_attachment.eks_cni_policy.id,
    aws_iam_role_policy_attachment.eks_ecr_readonly.id,
    aws_iam_role_policy_attachment.eks_cloudwatch.id,
    aws_iam_role_policy_attachment.eks_ssm.id
  ]
}

output "cert_manager_role_arn" {
  value = aws_iam_role.cert_manager.arn
}