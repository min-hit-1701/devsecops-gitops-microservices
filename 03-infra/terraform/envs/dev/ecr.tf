# ------------------------------------------------------------
# ECR Repositories — 5 microservices
# ------------------------------------------------------------

locals {
  ecr_services = ["ui", "cart", "orders", "catalog", "checkout"]
}

resource "aws_ecr_repository" "app_services" {
  for_each = toset(local.ecr_services)

  name                 = "${var.environment_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name       = "${var.environment_name}-${each.key}"
    Service    = each.key
    created-by = "uit-devsecops-gitops"
  }
}

resource "aws_ecr_lifecycle_policy" "app_services" {
  for_each = aws_ecr_repository.app_services

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
