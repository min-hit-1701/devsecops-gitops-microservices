# Noi dung bao cao tien do tuan toi

## 1) Da lam gi den hien tai

- Da cap nhat ten de tai theo huong dan GVHD.
- Da phan tich 3 repo mau va chot sample app: `aws-containers/retail-store-sample-app`.
- Da cap nhat mo hinh kien truc tu CI/CD cu sang DevSecOps + GitOps.
- Da tao ban so sanh mo hinh cu va moi theo tung thanh phan.
- Da tao workspace do an chuan de quan ly cong viec va bang chung.
- Da tao khung cho App Repo, GitOps Repo, IaC, CI, Security, Observability.
- Da chuan bi san Terraform backend code (S3 state + DynamoDB lock).

## 2) Dang lam

- Hoan thien moi truong cong cu (Terraform, kubectl, Helm, Docker).
- Provision backend Terraform tren AWS.

## 3) Sap toi se lam

1. Provision ha tang dev (VPC, ECR, EKS minimal).
2. Cai Jenkins va cau hinh CI voi security gates.
3. Push image len ECR va cap nhat tag vao GitOps repo.
4. Cai Argo CD va thuc hien sync len EKS.
5. Demo rollback bang git revert tren GitOps repo.
6. Hoan thien monitoring co ban va bao cao evidence.

## 4) Rui ro chinh

- Chi phi AWS va quota tai khoan moi.
- Loi cau hinh IAM/RBAC khi tich hop EKS + Argo CD.

## 5) Cach trinh bay voi thay (goi y)

- 5 phut: cap nhat de tai va mo hinh moi.
- 5 phut: da lam duoc gi (workspace, sample app, khung backend).
- 5 phut: ke hoach tuan toi + rui ro + cach kiem soat.
