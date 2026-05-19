variable "aws_region" {
  description = "AWS region for dev environment"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment_name" {
  description = "Environment/project name used by sample Terraform module"
  type        = string
  default     = "uit-devsecops-dev"
}

variable "istio_enabled" {
  description = "Enable Istio addons"
  type        = bool
  default     = false
}

variable "opentelemetry_enabled" {
  description = "Enable OpenTelemetry addons"
  type        = bool
  default     = false
}

variable "node_instance_type" {
  description = "Node instance type for EKS managed nodes"
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

variable "enable_third_node_group" {
  description = "Enable third node group"
  type        = bool
  default     = false
}
