# Terraform Env Dev

Contains tfvars and main configuration for the dev environment.

## Backend Config

You can use the file:

- `backend.hcl.example`

When initializing the dev module:

```bash
terraform init -backend-config=backend.hcl.example
```

## Key Files

- `backend.tf`
- `versions.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Execution Sequence

### 0) Select the Correct AWS Profile (Important)

In PowerShell, set the profile for the current session:

```powershell
$env:AWS_PROFILE = "uit-devsecops"
aws sts get-caller-identity
```

If the ARN is not `...:user/uit-devsecops-gitops-deployer`, stop and check the profile.

1. Copy the sample variables:

```bash
copy terraform.tfvars.example terraform.tfvars
```

2. Init with remote backend:

```bash
terraform init -reconfigure -backend-config=backend.hcl.example
```

3. Validate and plan:

```bash
terraform validate
terraform plan
```

4. Apply:

```bash
terraform apply -auto-approve
```

Note: The default minimal EKS module for the sample app creates node group with `m5.large` instances (high cost). Before applying in production, confirm the cost strategy.

### Recommended Configuration for the Project (balance stability and cost)

- `node_instance_type = "t3.medium"`
- `node_min_size = 1`
- `node_desired_size = 1`
- `node_max_size = 2`
- `enable_third_node_group = false`

Goal: avoid insufficient resources that cause pod scheduling errors, while avoiding overly expensive configurations like `m5.large` on 3 node groups.
