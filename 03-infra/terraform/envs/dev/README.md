# Terraform Env Dev

Noi dat tfvars va main cho moi truong dev.

## Backend config

Ban co the dung file:

- `backend.hcl.example`

Khi init module dev:

```bash
terraform init -backend-config=backend.hcl.example
```

## Cac file chinh

- `backend.tf`
- `versions.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Trinh tu chay

### 0) Chot AWS profile dung (quan trong)

Trong PowerShell, set profile cho phien hien tai:

```powershell
$env:AWS_PROFILE = "uit-devsecops"
aws sts get-caller-identity
```

Neu ARN khong phai `...:user/uit-devsecops-gitops-deployer` thi dung lai va kiem tra profile.

1. Copy bien mau:

```bash
copy terraform.tfvars.example terraform.tfvars
```

2. Init voi remote backend:

```bash
terraform init -reconfigure -backend-config=backend.hcl.example
```

3. Validate va plan:

```bash
terraform validate
terraform plan
```

4. Apply:

```bash
terraform apply -auto-approve
```

Luu y: module EKS minimal cua sample app mac dinh tao node group instance `m5.large` (chi phi cao). Truoc khi apply thuc te, can chot chien luoc chi phi.

### Cau hinh khuyen nghi cho do an (can bang on dinh va chi phi)

- `node_instance_type = "t3.medium"`
- `node_min_size = 1`
- `node_desired_size = 1`
- `node_max_size = 2`
- `enable_third_node_group = false`

Muc tieu: khong qua it tai nguyen de tranh loi pod scheduling, nhung van tranh cau hinh qua ton kem nhu `m5.large` tren 3 node group.
