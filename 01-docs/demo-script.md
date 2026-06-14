# ============================================================
# KỊCH BẢN DEMO ĐỒ ÁN — DevSecOps + GitOps trên AWS
# Thời gian dự kiến: 25-30 phút
# ============================================================

# Chuẩn bị trước khi demo:
# 1. Mở sẵn 2 màn hình: terminal (full-screen) + trình duyệt (AWS Console + GitHub)
# 2. Đảm bảo node đã scale lên (1 node t3.large)
# 3. Đảm bảo cluster đang chạy với 5 service retail-store

# ==================================================================
# PHẦN 1: GIỚI THIỆU KIẾN TRÚC (3 phút)
# ==================================================================

# Slide 1: Kiến trúc tổng thể
# → Trình bày sơ đồ: Developer → GitHub → Jenkins → SonarQube/OWASP/Trivy → ECR → Argo CD → EKS
# → Nhấn mạnh: 2 repo model, shift-left security, GitOps single source of truth

# Slide 2: Công nghệ sử dụng
# → IaC: Terraform
# → CI: Jenkins + Kaniko
# → Security: SonarQube, OWASP DC, Trivy, Checkov/Terrascan, Kyverno
# → CD: Argo CD + Kustomize + Helm


# ==================================================================
# PHẦN 2: GITHUB — 3 REPOSITORY (3 phút)
# ==================================================================

# Mở trình duyệt, show từng repo:

# Repo 1: Project Repo (code + cấu hình)
# https://github.com/min-hit-1701/devsecops-gitops-microservices
# → Show cấu trúc thư mục: 03-infra, 04-platform, 05-ci, 06-security, 07-observability
# → Show Terraform modules: modules/vpc/, modules/eks/, modules/ecr/
# → Show Jenkins shared library: 05-ci/jenkins-shared-library/vars/
# → Show Kyverno policies: 06-security/policies/
# → Show Prometheus alerts: 07-observability/alerts/

# Repo 2: App Repo (mã nguồn 5 microservice)
# https://github.com/min-hit-1701/retail-store-app
# → Show Jenkinsfile (dùng shared library, AWS credentials plugin)
# → Show src/ thư mục: ui, cart, orders, catalog, checkout

# Repo 3: GitOps Repo (manifest triển khai)
# https://github.com/min-hit-1701/retail-store-gitops
# → Show umbrella Chart.yaml (Helm)
# → Show values.yaml + overlays/dev/values-dev.yaml
# → Show argocd/applications/retail-store-dev.yaml


# ==================================================================
# PHẦN 3: TERRAFORM — INFRASTRUCTURE AS CODE (3 phút)
# ==================================================================

# Mở terminal, chạy:

$env:AWS_PROFILE = "uit-devsecops"
$env:AWS_REGION = "ap-southeast-1"

# 1. Show Terraform state backend
aws s3 ls s3://uit-devsecops-gitops-dev-0a502713-tfstate/envs/dev/
# → State lưu trên S3, lock qua DynamoDB

# 2. Show Terraform plan (chứng minh code khớp hạ tầng)
cd D:\DACN\do-an-devsecops-gitops\03-infra\terraform\envs\dev
terraform plan -var-file="terraform.tfvars"
# → Đọc dòng cuối: "Plan: 0 to add, 0 to change, 0 to destroy"
# → Chứng minh: toàn bộ hạ tầng quản lý bởi Terraform, không drift

# 3. Show Terraform modules
# → Mở file 03-infra/terraform/modules/vpc/main.tf trong IDE
# → Mở file 03-infra/terraform/modules/eks/main.tf
# → Mở file 03-infra/terraform/modules/ecr/main.tf
# → Nhấn mạnh: mỗi module có variables.tf, outputs.tf, versions.tf


# ==================================================================
# PHẦN 4: AWS CONSOLE — HẠ TẦNG THỰC TẾ (3 phút)
# ==================================================================

# Mở trình duyệt → AWS Console (ap-southeast-1)

# 1. EKS Dashboard
# EKS → Clusters → uit-devsecops-dev → tab Overview
# → Show: status Active, K8s v1.33

# 2. EKS → tab Compute
# → Show: 3 node groups (managed-nodegroup-1, -2, -large)
# → Giải thích: t3.medium dùng hàng ngày, t3.large dùng khi build

# 3. ECR → Repositories  
# → Show: 5 repos (uit-devsecops-dev-*)
# → Click vào uit-devsecops-dev-ui → show image latest 396MB
# → Chứng minh: image đã được push từ CI pipeline

# 4. VPC Dashboard
# → Show VPC uit-devsecops-dev, 6 subnets, Internet Gateway, NAT Gateway

# 5. CloudWatch → Log groups
# → Show /aws/eks/uit-devsecops-dev/cluster
# → Show retention 90 days, log size


# ==================================================================
# PHẦN 5: KUBERNETES — CLUSTER & 5 MICROSERVICES (3 phút)
# ==================================================================

# Terminal:

# 1. Kết nối cluster
aws eks --region ap-southeast-1 update-kubeconfig --name uit-devsecops-dev

# 2. Nodes
kubectl get nodes
# → Show: 1 node Ready, t3.large

# 3. Tất cả pods
kubectl get pods -A
# → Show: 32 pods, tất cả Running
# → Chỉ ra: Argo CD (7 pods), Jenkins (1 pod), Monitoring (7 pods), 
#            Cert Manager (3 pods), kube-system (5 pods), Retail Store (5 pods)

# 4. Retail Store services
kubectl get all -n retail-store-dev
# → Show: 5 Deployment + 5 Service, tất cả Ready

# 5. Test từng service
kubectl logs deploy/dev-catalog -n retail-store-dev --tail=3
# → "Using in-memory database" — service hoạt động
kubectl logs deploy/dev-checkout -n retail-store-dev --tail=3
kubectl logs deploy/dev-ui -n retail-store-dev --tail=3
# → Spring Boot started


# ==================================================================
# PHẦN 6: ARGO CD — GITOPS (3 phút)
# ==================================================================

# Terminal:
kubectl port-forward -n argocd svc/argocd-server 8081:443
# → Mở trình duyệt: https://localhost:8081
# → Login: admin / <password>
# → Show Application retail-store-dev
# → Status: Synced + Healthy
# → Click vào application → show resource tree: 5 Deployment, 5 Service, 5 ReplicaSet, 5 Pod
# → Chứng minh: Argo CD quản lý toàn bộ trạng thái cluster từ GitOps repo


# ==================================================================
# PHẦN 7: CI PIPELINE — JENKINS + KANIKO (3 phút)
# ==================================================================

# 1. Jenkins UI
kubectl port-forward -n jenkins jenkins-0 8082:8080
# → Mở trình duyệt: http://localhost:8082
# → Login: admin / devsecops2026
# → Show: Jenkins đã deploy lên EKS

# 2. Kaniko build jobs
kubectl get jobs -n jenkins
# → Show: 4 jobs Completed (kaniko-build-*)
# → Đây là CI pipeline dùng Kaniko — build Docker image không cần Docker daemon

# 3. Show Jenkinsfile
# → Mở file 05-ci/jenkins/Jenkinsfile trong IDE
# → Show: @Library('devsecops-shared-library') — dùng shared library
# → Show: 6 stage pipeline: Checkout → AWS Setup → Build → SonarQube → OWASP → Docker+Push
# → Nhấn mạnh: 3 security gates, không hardcode AWS account ID


# ==================================================================
# PHẦN 8: SECURITY (3 phút)
# ==================================================================

# 1. Security Gates code
# → Mở 05-ci/jenkins-shared-library/vars/sonarQubeAnalysis.groovy
# → Mở 05-ci/jenkins-shared-library/vars/owaspDependencyCheck.groovy
# → Mở 05-ci/jenkins-shared-library/vars/dockerBuildAndPush.groovy (Trivy)

# 2. Kyverno policies (Policy as Code)
# → Mở 06-security/policies/disallow-root-containers.yaml
# → Mở 06-security/policies/require-resource-limits.yaml
# → Show: 5 policies, Enforce mode

# 3. IaC Security — Terrascan
# → Mở 06-security/scan-reports/terrascan-scan.json
# → Show: 198 policies validated, 0 HIGH, 0 MEDIUM
# → Show 06-security/README.md — các issue đã fix


# ==================================================================
# PHẦN 9: OBSERVABILITY — PROMETHEUS + GRAFANA (2 phút)
# ==================================================================

# 1. Prometheus (terminal)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# → Mở http://localhost:9090
# → Show targets: all UP

# 2. Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# → Mở http://localhost:3000
# → Login: admin / devsecops2026
# → Show dashboard: "Retail Store — DevSecOps Dashboard"
# → 10 panels: CPU, Memory, Network, Disk, Pods

# 3. Alerting rules
# → Mở 07-observability/alerts/prometheus-rules.yaml
# → Show: 10 alert rules (NodeDown, HighCPU, PodCrashLooping, etc.)


# ==================================================================
# PHẦN 10: DEMO ROLLBACK — GIT REVERT (3 phút)
# ==================================================================

# Bước 1: Push thay đổi image tag vào GitOps repo
cd D:\DACN\do-an-devsecops-gitops\02-repos\gitops-repo
# Sửa image tag trong overlays/dev/kustomization.yaml
# Commit & push

# Bước 2: Argo CD sync
# Show Argo CD UI → Application retail-store-dev → Refresh → Sync

# Bước 3: Rollback
git revert HEAD --no-edit
git push origin main

# Bước 4: Argo CD auto-sync phát hiện commit revert → quay về phiên bản cũ
# Show Argo CD UI → OutOfSync → Synced
# Chứng minh: Rollback = git revert, không cần kubectl


# ==================================================================
# PHẦN 11: COST MANAGEMENT (1 phút)
# ==================================================================

# Terminal:
# Scale node về 0 sau demo
aws eks update-nodegroup-config \
  --cluster-name uit-devsecops-dev \
  --nodegroup-name managed-nodegroup-large \
  --scaling-config minSize=0,desiredSize=0,maxSize=1 \
  --region ap-southeast-1

kubectl get nodes
# → No resources found

# Khi cần làm tiếp: scale node lên 1 → tất cả pod tự chạy lại
