variable "resource_name" {
  description = "The resource name"
  type        = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (cost saving) vs one per AZ (HA)"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
  default = {}
}