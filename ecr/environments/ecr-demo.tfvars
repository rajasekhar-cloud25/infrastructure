############################
# Example terraform.tfvars
############################

aws_region              = "us-east-1"
basic_scan_type_version = "AWS_NATIVE"
scan_type               = "ENHANCED"

# ─── Scanning Rules ───
scanning_rules = [
  {
    scan_frequency = "CONTINUOUS_SCAN"
    filter         = "prod-*"
    filter_type    = "WILDCARD"
  },
  {
    scan_frequency = "SCAN_ON_PUSH"
    filter         = "staging-*"
    filter_type    = "WILDCARD"
  },
  {
    scan_frequency = "SCAN_ON_PUSH"
    filter         = "*"
    filter_type    = "WILDCARD"
  }
]

# ─── Repositories ───
repositories = [
  {
    name                 = "prod-frontend"
    image_tag_mutability = "IMMUTABLE"
    encryption_type      = "AES256"
    force_delete         = false
    tags = {
      Team = "frontend"
    }
  },
  {
    name                 = "prod-backend"
    image_tag_mutability = "IMMUTABLE"
    encryption_type      = "AES256"
    force_delete         = false
    tags = {
      Team = "backend"
    }
  },
  {
    name                 = "staging-api"
    image_tag_mutability = "MUTABLE"
    encryption_type      = "AES256"
    force_delete         = true
    tags = {
      Team = "backend"
    }
  }
]

# ─── Lifecycle Defaults ───
default_untagged_expiry_days = 14
default_max_image_count      = 30

# ─── Cross-Account Access (uncomment to enable) ───
# cross_account_arns = [
#   "arn:aws:iam::root",
#   "arn:aws:iam::root"
# ]

# ─── Replication (uncomment to enable) ───
# replication_rules = [
#   {
#     destinations = [
#       {
#         region      = "eu-west-1"
#         registry_id = ""
#       }
#     ]
#     repository_filters = [
#       {
#         filter      = "prod-*"
#         filter_type = "PREFIX_MATCH"
#       }
#     ]
#   }
# ]

# ─── Pull-Through Cache (uncomment to enable) ───
# pull_through_cache_rules = [
#   {
#     ecr_repository_prefix = "ecr-public"
#     upstream_registry_url = "public.ecr.aws"
#   },
#   {
#     ecr_repository_prefix = "docker-hub"
#     upstream_registry_url = "registry-1.docker.io"
#   }
# ]

# ─── Tags ───
common_tags = {
  ManagedBy   = "terraform"
  Project     = "ecr"
  Environment = "production"
}
