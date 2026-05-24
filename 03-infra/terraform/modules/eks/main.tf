data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.9"

  cluster_name    = var.environment_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = [var.node_instance_type]
    capacity_type  = "ON_DEMAND"
  }

  eks_managed_node_groups = {
    node_group_1 = {
      name           = "managed-nodegroup-1"
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      subnet_ids     = [var.private_subnet_ids[0]]
      instance_types = [var.node_instance_type]
    }
    node_group_2 = {
      name           = "managed-nodegroup-2"
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      subnet_ids     = [var.private_subnet_ids[1]]
      instance_types = [var.node_instance_type]
    }
  }

  tags = {
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

# Third node group (optional, disabled by default)
resource "aws_eks_node_group" "third" {
  count = var.enable_third_node_group ? 1 : 0

  cluster_name    = module.eks.cluster_name
  node_group_name = "managed-nodegroup-3"
  node_role_arn   = module.eks.iam_role_arn

  subnet_ids = [var.private_subnet_ids[min(2, length(var.private_subnet_ids) - 1)]]

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"
}

# AWS Load Balancer Controller
module "lb_controller" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    enable_helm_release = true
  }

  enable_cert_manager = true
  cert_manager = {
    enable_helm_release = true
  }
}

# Helm & Kubernetes providers configured to use the created cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ADOT Addon (OpenTelemetry)
resource "aws_eks_addon" "adot" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "adot"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    collector = {}
  })
}
