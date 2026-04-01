terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.6"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

# data "aws_eks_cluster" "main" {
#   name = module.eks.cluster_name
# }

#Ephemeral token — short lived, never stored in state
# ephemeral "aws_eks_cluster_auth" "main" {
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "https://localhost")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_ca_certificate), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", try(module.eks.cluster_name, "placeholder"), "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = try(module.eks.cluster_endpoint, "https://localhost")
    cluster_ca_certificate = try(base64decode(module.eks.cluster_ca_certificate), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", try(module.eks.cluster_name, "placeholder"), "--region", var.aws_region]
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
  load_config_file = false
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}