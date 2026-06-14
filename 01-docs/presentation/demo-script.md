# Demo Script — 4 phút

## PHẦN 1: Giới thiệu (30 giây)

> Thưa thầy, đồ án của em là thiết kế quy trình DevSecOps kết hợp GitOps
> cho hệ thống microservices trên AWS. Em dùng 5 service của ứng dụng bán lẻ mẫu,
> triển khai qua 4 giai đoạn: hạ tầng, CI, CD, monitoring.

---

## PHẦN 2: Hạ tầng — Terraform IaC (45 giây)

> **Mở AWS Console > EKS > Clusters > uit-devsecops-dev**
> 
> Toàn bộ hạ tầng được quản lý bằng Terraform:
> - VPC 10.0.0.0/16, 6 subnets, NAT Gateway
> - EKS cluster v1.33, 2 managed node groups t3.medium
> - 5 ECR repositories cho 5 service
> 
> **Mở tab ECR > Repositories > 5 repos**
> 
> Terraform state lưu trên S3, lock qua DynamoDB. Code nằm ở repo GitHub.

---

## PHẦN 3: CD GitOps — Argo CD + Kustomize (45 giây)

> **Mở Argo CD UI (port-forward localhost:8081 hoặc URL ALB)**
> 
> Em dùng mô hình 2-repo:
> - App Repo chứa mã nguồn + Jenkinsfile
> - GitOps Repo chứa Kustomize + Helm manifests
> 
> Argo CD theo dõi GitOps repo, tự động sync mỗi 3 phút.
> 
> **Click vào Application retail-store-dev**
> 
> Hiện tại 5 Service và 5 Deployment đã deploy. Pod ở trạng thái
> ImagePullBackOff vì ECR trống — đây là flow DevSecOps chuẩn: CI chưa
> chạy nên chưa có image. Khi CI push là Argo CD tự sync.

---

## PHẦN 4: CI Pipeline — Jenkins + Shared Library (30 giây)

> **Mở Jenkins UI (port-forward localhost:8080)**
> 
> CI pipeline em viết dưới dạng Shared Library với 6 hàm tái sử dụng.
> 3 security gate:
> - SonarQube SAST — phân tích mã nguồn tĩnh
> - OWASP Dependency Check — quét CVE trong dependency
> - Trivy — quét Docker image
> 
> **Mở GitHub > Jenkinsfile (shared library version)**
> 
> Code đã sẵn sàng, Jenkins đang chạy trên EKS.

---

## PHẦN 5: Observability + Security (30 giây)

> **Mở Grafana (port-forward localhost:3000)**
> 
> Prometheus + Grafana đã deploy, dashboard giám sát CPU, memory, network.
> 10 alert rules: NodeDown, HighCPU, PodCrashLooping, KubeAPIDown...
> 
> **Mở GitHub > 06-security/policies/**
> 
> Policy as Code: 5 Kyverno policies — chặn container root, yêu cầu
> resource limits + probes, cấm tag latest.
> 
> Terrascan scan Terraform: 198 policies, 0 lỗi.

---

## PHẦN 6: Tổng kết (30 giây)

> Thưa thầy, em đã hoàn thành:
> - Hạ tầng AWS toàn bộ bằng Terraform
> - Argo CD GitOps auto-sync
> - Jenkins CI pipeline code
> - Prometheus + Grafana monitoring
> - Policy as Code + IaC scanning
> 
> Còn 1 việc cuối: build Docker image push ECR để pipeline chạy end-to-end.
> Code đã đầy đủ trên 3 GitHub repo.
> 
> Em xin cảm ơn thầy.

---

## CHUẨN BỊ TRƯỚC BUỔI DEMO

Mở sẵn các tab sau (để chuyển nhanh):

| # | Tab | Mục đích |
|---|---|---|
| 1 | AWS Console > EKS > uit-devsecops-dev | Chứng minh cluster tồn tại |
| 2 | AWS Console > ECR > Repositories | 5 repos đã tạo |
| 3 | Argo CD UI | CD pipeline |
| 4 | Jenkins UI (localhost:8080) | CI pipeline |
| 5 | Grafana (localhost:3000) | Monitoring |
| 6 | GitHub > retail-store-gitops > apps/retail-store | Helm + Kustomize |
| 7 | GitHub > devsecops-gitops-microservices > 05-ci | Shared library |
| 8 | Terminal: kubectl get pods -A | Tổng quan cluster |

## CÁC LỆNH CẦN CHẠY TRƯỚC DEMO

```powershell
# 1. Scale node lên
$env:AWS_PROFILE = "uit-devsecops"
aws eks update-nodegroup-config --cluster-name uit-devsecops-dev --nodegroup-name <nodegroup-1> --scaling-config minSize=1,desiredSize=1,maxSize=2 --region ap-southeast-1
aws eks update-nodegroup-config --cluster-name uit-devsecops-dev --nodegroup-name <nodegroup-2> --scaling-config minSize=1,desiredSize=1,maxSize=2 --region ap-southeast-1

# 2. Kubeconfig
aws eks --region ap-southeast-1 update-kubeconfig --name uit-devsecops-dev

# 3. Port-forward Jenkins
kubectl port-forward -n jenkins jenkins-0 8080:8080

# 4. Port-forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# 5. Port-forward Argo CD (nếu cần)
kubectl port-forward -n argocd svc/argocd-server 8081:443
```
