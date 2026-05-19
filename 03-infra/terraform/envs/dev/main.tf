module "eks_minimal" {
  source = "../../../../02-repos/app-repo/terraform/eks/minimal"

  environment_name      = var.environment_name
  istio_enabled         = var.istio_enabled
  opentelemetry_enabled = var.opentelemetry_enabled

  node_instance_type      = var.node_instance_type
  node_min_size           = var.node_min_size
  node_desired_size       = var.node_desired_size
  node_max_size           = var.node_max_size
  enable_third_node_group = var.enable_third_node_group
}
