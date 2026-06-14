# EKS Module
# Provisions an EKS cluster with managed node groups and addons.
# Uses terraform-aws-modules/eks + eks-blueprints-addons.

variable "environment_name" {
  description = "Environment name used for resource naming and tagging"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID for the cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for managed node groups"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum number of nodes per node group"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired number of nodes per node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes per node group"
  type        = number
  default     = 2
}
