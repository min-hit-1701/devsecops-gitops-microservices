# Project Roadmap - DevSecOps + GitOps + Microservices on AWS

## Tong quan 4 giai doan

### Phase 1 - Planning and Setup
- Chot de tai, scope, KPI ky thuat.
- Chon sample app (uu tien aws-containers/retail-store-sample-app).
- Tao 2 repo: app-repo va gitops-repo.
- Chuan hoa cau truc workspace.

Deliverables:
- Mo hinh tong quan
- Ke hoach cap nhat
- Backlog cong viec

### Phase 2 - Infrastructure as Code (Terraform)
- Tao AWS backend cho Terraform: S3 + DynamoDB.
- Provision VPC, subnets, security groups, IAM.
- Provision ECR va EKS (hoac phuong an low-cost).

Deliverables:
- Terraform code chay duoc
- Evidence `terraform plan/apply`

### Phase 3 - CI + Security Gates (Jenkins)
- Build/test static analysis dependency scan.
- Build image, Trivy scan, push ECR.
- Tu dong cap nhat image tag sang gitops-repo.

Deliverables:
- Jenkinsfile
- Ban ghi pass/fail theo gate
- Scan reports

### Phase 4 - CD GitOps + Observability
- Cai Argo CD, ket noi gitops repo.
- Sync app len EKS, kiem tra health.
- Thiết lap CloudWatch (va co the Grafana/Prometheus).

Deliverables:
- Argo CD app synced + healthy
- Demo rollback bang git revert
- Dashboard/log evidence

## Checklist de bao ve

- [ ] Co architecture final
- [ ] Co pipeline final
- [ ] Co security gate evidence
- [ ] Co rollback demo
- [ ] Co tong ket bai hoc va huong mo rong
