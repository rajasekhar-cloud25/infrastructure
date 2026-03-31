variable "resource_name" {
  type    = string
  default = "ecommerce-k8s-demo"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eip_count" {
  type    = number
  default = 2
}