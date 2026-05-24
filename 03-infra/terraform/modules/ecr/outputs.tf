output "repository_urls" {
  description = "Map of service name to ECR repository URL"
  value = {
    for repo in aws_ecr_repository.app :
    repo.name => repo.repository_url
  }
}

output "repository_names" {
  description = "Map of service name to ECR repository name"
  value = {
    for repo in aws_ecr_repository.app :
    repo.name => repo.name
  }
}
