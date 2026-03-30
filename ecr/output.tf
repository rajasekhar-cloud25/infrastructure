############################
# Outputs
############################

output "repository_urls" {
  description = "Map of repository name to URL"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository name to ARN"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}

output "registry_id" {
  description = "The registry ID (AWS account ID)"
  value       = try(values(aws_ecr_repository.this)[0].registry_id, null)
}

output "registry_scanning_configuration" {
  description = "The registry scanning configuration"
  value = {
    scan_type = aws_ecr_registry_scanning_configuration.this.scan_type
  }
}

output "account_setting" {
  description = "ECR account setting"
  value = {
    name  = aws_ecr_account_setting.basic_scan_type.name
    value = aws_ecr_account_setting.basic_scan_type.value
  }
}
