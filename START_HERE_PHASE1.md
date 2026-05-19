# Start Here - Phase 1 and 2 Kickoff

Sample app da chot: `aws-containers/retail-store-sample-app`.

## 1) Xac nhan AWS login

```bash
aws sts get-caller-identity
```

## 2) Cai tool con thieu (Windows)

```powershell
powershell -ExecutionPolicy Bypass -File .\09-scripts\setup-tools-windows.ps1
```

Sau do mo terminal moi va kiem tra:

```bash
terraform version
kubectl version --client
helm version
docker --version
```

## 3) Tao Terraform backend (S3 + DynamoDB)

```bash
cd 03-infra/terraform/backend
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform output backend_tf_snippet
```

## 4) Luu bang chung

- Screenshot `terraform plan` va `terraform apply`
- Luu vao `08-evidence/phase-2`

## 5) Sau khi backend xong

Buoc tiep theo la tao module ha tang dev:
- VPC/Subnet/SG
- ECR
- EKS (minimal)
