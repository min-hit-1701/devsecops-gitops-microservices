# Terraform Modules

Reusable modules for provisioning AWS infrastructure across environments.

## Modules

| Module | Description | Key Resources |
|---|---|---|
| `vpc/` | VPC with public/private subnets | VPC, subnets, NAT Gateway, Internet Gateway, route tables |
| `eks/` | EKS cluster with managed node groups | EKS cluster, node groups, LB Controller, Cert Manager, ADOT |
| `ecr/` | ECR repositories with lifecycle | ECR repos, lifecycle policies, image scanning |

## Usage

Each environment (dev, staging, prod) calls these modules with different parameters:

```hcl
# envs/dev/main.tf
module "vpc" {
  source              = "../../modules/vpc"
  environment_name    = "uit-devsecops-dev"
  vpc_cidr            = "10.0.0.0/16"
  single_nat_gateway  = true
}

module "eks" {
  source            = "../../modules/eks"
  environment_name  = "uit-devsecops-dev"
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  node_instance_type = "t3.medium"
}

module "ecr" {
  source           = "../../modules/ecr"
  environment_name = "uit-devsecops-dev"
}
```

## Environment Differences

| Setting | dev | staging | prod |
|---|---|---|---|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| NAT Gateway | Single (cost-saving) | Per-AZ | Per-AZ |
| Node instance | t3.medium | t3.medium | t3.large |
| Min nodes | 1 | 2 | 3 |
| Max nodes | 2 | 4 | 6 |
| Node groups | 2 | 2 | 3 |
| ECR mutability | MUTABLE | IMMUTABLE | IMMUTABLE |
| Max images | 10 | 20 | 30 |
