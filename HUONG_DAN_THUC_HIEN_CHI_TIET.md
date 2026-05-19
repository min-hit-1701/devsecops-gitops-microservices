# Huong Dan Thuc Hien Chi Tiet

Tai lieu nay la quy trinh lam do an tu dau den cuoi theo huong DevSecOps + GitOps + Microservices tren AWS.

## 0) Muc tieu dau ra cuoi cung

- Co pipeline CI co security gates (SonarQube, OWASP, Trivy).
- Co luong CD bang GitOps (Argo CD sync tu GitOps repo vao EKS).
- Co IaC bang Terraform (VPC, IAM, ECR, EKS, backend state).
- Co bang chung (log, screenshot, commit, ket qua rollback, dashboard).

## 1) Chuan bi (ngay 1)

1. AWS:
   - Tao Budget alarm (5 USD, 10 USD).
   - Chon 1 region co quota on dinh.
   - Tao IAM user/role toi thieu quyen de thao tac.
2. Cong cu local:
   - aws cli, terraform, kubectl, helm, docker, git.
3. Repo:
   - `02-repos/app-repo`
   - `02-repos/gitops-repo`
4. Tai lieu:
   - Cap nhat mo hinh va ke hoach trong `01-docs/`.

Checklist tham khao: `09-scripts/checklist-first-day.md`.

## 2) Lam IaC truoc (Phase 2)

Thu tu khuyen nghi:
1. Terraform backend (S3 + DynamoDB) trong `03-infra/terraform/backend`.
2. Module VPC + subnet + security group trong `03-infra/terraform/modules`.
3. Module ECR.
4. Module EKS (hoac phuong an low-cost neu can).
5. Env dev trong `03-infra/terraform/envs/dev`.

Moi buoc deu can:
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- Luu evidence vao `08-evidence/phase-2`.

## 3) CI va Security Gates (Phase 3)

Dat tai `05-ci/jenkins`:
1. Checkout source.
2. Build va unit test.
3. SonarQube analysis.
4. OWASP dependency check.
5. Docker build.
6. Trivy scan (fail neu High/Critical).
7. Push image len ECR.
8. Cap nhat image tag sang `gitops-repo`.

Policy gate dat tai `05-ci/security-gates`.
Bao cao scan luu tai `06-security/scan-reports`.

## 4) CD theo GitOps (Phase 4)

1. Cai Argo CD trong `04-platform/argocd`.
2. Tao Application truyen den `02-repos/gitops-repo`.
3. Verify sync va health.
4. Thu rollback bang `git revert` tren gitops repo.
5. Luu evidence tai `08-evidence/phase-4`.

## 5) Observability va bao mat van hanh

1. CloudWatch log/metric.
2. Dashboard co ban trong `07-observability/dashboards`.
3. Alert cho pipeline fail/pod crash trong `07-observability/alerts`.
4. Runbook su co trong `07-observability/runbooks`.

## 6) Cach lam viec voi mentor AI moi buoi

Gui theo mau:
- Goal hom nay:
- Trang thai hien tai:
- Loi gap phai (paste log):
- Ban da thu nhung gi:
- Muon ho tro phan nao:

Tai lieu tham khao: `WORKFLOW_WITH_ASSISTANT.md`.

## 7) Tieu chi hoan thanh de bao ve

- Pipeline pass tu dong cho 1 commit moi.
- Security gate chay dung va chan release khi co loi nghiem trong.
- Argo CD sync thanh cong, app healthy.
- Rollback bang git revert thanh cong.
- Co bo evidence day du cho 4 phase.
