# DevSecOps GitOps Microservices Thesis Workspace

Workspace nay duoc tao de ban trien khai do an theo huong:

- DevSecOps + GitOps
- Microservices
- AWS (EKS, ECR, IAM, VPC, CloudWatch)

## Folder structure

```text
do-an-devsecops-gitops/
  00-admin/                # quan ly tien do, meeting note, decision log
  01-docs/                 # tai lieu do an: architecture, bao cao, slide
  02-repos/                # clone 2 repo chinh: app-repo va gitops-repo
  03-infra/terraform/      # IaC: backend, modules, envs
  04-platform/             # argocd va cac addon kubernetes
  05-ci/                   # jenkins pipeline va cau hinh security gates
  06-security/             # threat model, policy, sbom, scan reports
  07-observability/        # dashboard, alerts, runbooks
  08-evidence/             # bang chung tung giai doan (anh, log, report)
  09-scripts/              # script ho tro setup, verify, cleanup
  10-agent-skill/          # file skill markdown
  PROJECT_ROADMAP.md       # lo trinh thuc hien do an theo giai doan
  WORKFLOW_WITH_ASSISTANT.md
```

## Cach dung nhanh

1. Dat source app tai `02-repos/app-repo`.
2. Dat gitops manifests tai `02-repos/gitops-repo`.
3. Lam IaC trong `03-infra/terraform`.
4. Cau hinh pipeline trong `05-ci/jenkins/Jenkinsfile`.
5. Luu bang chung chay thuc te vao `08-evidence/` theo tung phase.

## Nguyen tac lam do an

- Moi thay doi ha tang/phat hanh phai co bang chung (screenshot + log + link commit).
- Security gates fail thi khong release.
- CD theo GitOps: Jenkins khong deploy truc tiep vao cluster.
- Khi gap loi, ghi vao `00-admin/decision-log` va cap nhat huong xu ly.
