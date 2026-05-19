# Terraform Backend

Muc tieu:
- S3 bucket cho state
- DynamoDB cho lock

## File trong thu muc nay

- `versions.tf`
- `providers.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Cach dung nhanh

1. Tao file bien thuc te:
   - copy `terraform.tfvars.example` thanh `terraform.tfvars`
2. Chay cac lenh:

```bash
terraform init
terraform plan
terraform apply
```

3. Sau khi apply xong, lay output:

```bash
terraform output backend_tf_snippet
```

Dung output nay de cau hinh backend `s3` cho cac module Terraform khac.

## Luu y

- Khong commit credentials.
- Dung profile hoac role.
- Bat budget alarm truoc khi provision.
