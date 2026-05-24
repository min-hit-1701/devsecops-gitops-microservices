# ECR Module
# Creates ECR repositories for all microservices with lifecycle policies.

variable "environment_name" {
  description = "Environment name used for repository naming"
  type        = string
}

variable "services" {
  description = "List of microservice names"
  type        = list(string)
  default     = ["ui", "cart", "orders", "catalog", "checkout"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "max_image_count" {
  description = "Maximum number of images to retain per repository"
  type        = number
  default     = 10
}
