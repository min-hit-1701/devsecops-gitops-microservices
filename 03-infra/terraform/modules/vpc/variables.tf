# VPC Module
# Provisions a VPC with public/private subnets, NAT Gateway, and Internet Gateway.
# Tags subnets automatically for EKS auto-discovery.

variable "environment_name" {
  description = "Environment name used for resource naming and tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway to reduce cost (dev only)"
  type        = bool
  default     = true
}

variable "az_count" {
  description = "Number of Availability Zones"
  type        = number
  default     = 3
}
