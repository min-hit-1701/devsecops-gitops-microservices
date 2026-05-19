output "configure_kubectl" {
  description = "Command to configure kubectl for created EKS cluster"
  value       = module.eks_minimal.configure_kubectl
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for all microservices"
  value = {
    for repo in aws_ecr_repository.app_services :
    repo.name => repo.repository_url
  }
}
