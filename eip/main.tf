terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_eip" "nlb" {
  count  = var.eip_count
  domain = "vpc"

  tags = {
    Name      = "${var.resource_name}-nlb-eip-${count.index}"
    ManagedBy = "Terraform"
    Project   = var.resource_name
  }
}