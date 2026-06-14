# Bao cao tien do Week 02 (outline)

## 1) Da lam duoc

- Chot sample app: `aws-containers/retail-store-sample-app`.
- Hoan thien workspace do an theo phase.
- Khoi tao app-repo va gitops-repo skeleton.
- Viet Terraform backend module (S3 state + DynamoDB lock).
- Cai dat/verify toolchain local:
  - Terraform
  - kubectl
  - Helm
  - Docker
- Chay duoc `terraform init` va `terraform plan` cho backend.

## 2) Van de gap phai va cach xu ly

- Ban dau `terraform apply` bi chan boi IAM permissions.
- Da doi sang user moi dung ten do an: `uit-devsecops-gitops-deployer`.
- Da cap nhat policy theo prefix tai nguyen du an va giai quyet cac loi read/refresh cua provider.
- Ket qua cuoi: `terraform apply` va `terraform output` da thanh cong.

## 3) Ket qua ky thuat hien tai

- Backend da tao thanh cong:
  - S3 state bucket: `uit-devsecops-gitops-dev-0a502713-tfstate`
  - DynamoDB lock table: `uit-devsecops-gitops-dev-0a502713-tflock`
- Da co output backend snippet de dua vao cac module Terraform tiep theo.

## 4) Ke hoach week tiep theo

1. Hoan thanh backend provisioning.
2. Tao ha tang dev (VPC, ECR, EKS minimal).
3. Tao Jenkins pipeline skeleton + security gates.
4. Chuan bi GitOps manifests ban dau va Argo CD app definition.

## 5) Ghi chu voi GVHD

- Tien do ky thuat dang dung huong.
- Blocker hien tai la phan quyen IAM account moi.
- Neu duoc cap quyen trong tuan nay, co the tiep tuc dung roadmap da dat.
