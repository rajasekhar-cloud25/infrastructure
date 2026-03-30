############################
# ECR Terraform Configuration
############################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# ECR Account Setting
# ─────────────────────────────────────────────
resource "aws_ecr_account_setting" "basic_scan_type" {
  name  = "BASIC_SCAN_TYPE_VERSION"
  value = var.basic_scan_type_version
}

# ─────────────────────────────────────────────
# ECR Registry Scanning Configuration
# ─────────────────────────────────────────────
resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = var.scan_type

  dynamic "rule" {
    for_each = var.scanning_rules
    content {
      scan_frequency = rule.value.scan_frequency

      repository_filter {
        filter      = rule.value.filter
        filter_type = rule.value.filter_type
      }
    }
  }
}

# ─────────────────────────────────────────────
# ECR Repositories
# ─────────────────────────────────────────────
resource "aws_ecr_repository" "this" {
  for_each = { for repo in var.repositories : repo.name => repo }

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  # NOTE: image_scanning_configuration (scan_on_push) is DEPRECATED.
  # Use aws_ecr_registry_scanning_configuration instead (defined above).

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.kms_key_arn : null
  }

  force_delete = each.value.force_delete

  tags = merge(var.common_tags, each.value.tags)
}

# ─────────────────────────────────────────────
# ECR Lifecycle Policies
# ─────────────────────────────────────────────
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = { for repo in var.repositories : repo.name => repo if repo.lifecycle_policy != null }

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.lifecycle_policy
}

# Default lifecycle policy for repos without a custom one
resource "aws_ecr_lifecycle_policy" "default" {
  for_each = { for repo in var.repositories : repo.name => repo if repo.lifecycle_policy == null }

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than ${var.default_untagged_expiry_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.default_untagged_expiry_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.default_max_image_count} tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["v"]
          countType   = "imageCountMoreThan"
          countNumber = var.default_max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ─────────────────────────────────────────────
# ECR Repository Policies (cross-account access)
# ─────────────────────────────────────────────
resource "aws_ecr_repository_policy" "this" {
  for_each = { for repo in var.repositories : repo.name => repo if length(var.cross_account_arns) > 0 }

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = var.cross_account_arns
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages",
        ]
      }
    ]
  })
}

# ─────────────────────────────────────────────
# ECR Registry Policy (optional)
# ─────────────────────────────────────────────
resource "aws_ecr_registry_policy" "this" {
  count = var.registry_policy != null ? 1 : 0

  policy = var.registry_policy
}

# ─────────────────────────────────────────────
# ECR Replication Configuration (optional)
# ─────────────────────────────────────────────
resource "aws_ecr_replication_configuration" "this" {
  count = length(var.replication_rules) > 0 ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.replication_rules
      content {
        dynamic "destination" {
          for_each = rule.value.destinations
          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }

        dynamic "repository_filter" {
          for_each = rule.value.repository_filters
          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }
}

# ─────────────────────────────────────────────
# ECR Pull-Through Cache Rules (optional)
# ─────────────────────────────────────────────
resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each = { for rule in var.pull_through_cache_rules : rule.ecr_repository_prefix => rule }

  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
}
