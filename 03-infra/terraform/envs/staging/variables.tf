variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment_name" {
  description = "Environment name used for all resource naming"
  type        = string
  default     = "uit-devsecops-dev"
}

variable "node_instance_type" {
  description = "EC2 instance type for managed node groups"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum nodes per node group"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired nodes per node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum nodes per node group"
  type        = number
  default     = 2
}
