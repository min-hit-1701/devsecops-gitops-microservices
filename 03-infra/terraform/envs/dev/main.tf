# ============================================================
# Dev Environment — VPC + EKS + ECR
# ============================================================

module "vpc" {
  source = "../../modules/vpc"

  environment_name   = var.environment_name
  vpc_cidr           = "10.0.0.0/16"
  single_nat_gateway = true
  az_count           = 3
}

module "eks" {
  source = "../../modules/eks"

  environment_name   = var.environment_name
  cluster_version    = "1.33"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_instance_type = var.node_instance_type
  node_min_size      = var.node_min_size
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size
}

module "ecr" {
  source = "../../modules/ecr"

  environment_name     = var.environment_name
  image_tag_mutability = "MUTABLE"
  max_image_count      = 10
}
