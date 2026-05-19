variable "aws_region" {
  description = "AWS region for Terraform backend resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project identifier for naming and tagging"
  type        = string
  default     = "uit-devsecops-gitops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner or team name"
  type        = string
  default     = "uit-student"
}
