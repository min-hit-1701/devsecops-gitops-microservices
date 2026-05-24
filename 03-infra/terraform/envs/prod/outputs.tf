output "configure_kubectl" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = module.eks.configure_kubectl
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for all microservices"
  value       = module.ecr.repository_urls
}
