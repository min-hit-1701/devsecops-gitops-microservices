# BÁO CÁO TIẾN ĐỘ ĐỒ ÁN — Cập nhật tuần 03

**Sinh viên:** Hồ Nhật Minh (MSSV: 23520924)  
**GVHD:** Lê Anh Tuấn  
**Ngày:** 07/05/2026  

---

## Mục lục
1. [Tổng quan những gì đã làm](#1-tổng-quan-những-gì-đã-làm)
2. [Chi tiết kỹ thuật từng giai đoạn](#2-chi-tiết-kỹ-thuật-từng-giai-đoạn)
3. [Kiến trúc tổng thể](#3-kiến-trúc-tổng-thể)
4. [Kiểm thử & xác minh hệ thống](#4-kiểm-thử--xác-minh-hệ-thống)
5. [Quản lý chi phí](#5-quản-lý-chi-phí)
6. [Kế hoạch tiếp theo](#6-kế-hoạch-tiếp-theo)
7. [Rủi ro & cách kiểm soát](#7-rủi-ro--cách-kiểm-soát)

---

## 1. Tổng quan những gì đã làm

### Phase 1: Lập kế hoạch & setup — **HOÀN THÀNH 100%**

| Hạng mục | Trạng thái |
|---|---|
| Cập nhật tên đề tài theo hướng dẫn GVHD | ✅ |
| Chọn sample app (aws-containers/retail-store-sample-app) | ✅ |
| Vẽ sơ đồ kiến trúc DevSecOps + GitOps bằng Mermaid | ✅ |
| Tạo workspace chuẩn 10 danh mục (00-admin đến 10-agent-skill) | ✅ |
| So sánh mô hình cũ (Java/Tomcat/EC2) và mới (Microservices/K8s) | ✅ |
| Tạo khung App Repo, GitOps Repo, IaC, CI, Security, Observability | ✅ |
| Cài đặt toolchain (Terraform, kubectl, Helm, Docker) | ✅ |
| Thiết lập AWS CLI profile & IAM user `uit-devsecops-gitops-deployer` | ✅ |

### Phase 2: Infrastructure as Code — 40% (ĐANG TIẾN HÀNH)

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| Terraform backend (S3 + DynamoDB) | ✅ | Đã deploy trên AWS |
| VPC (10.0.0.0/16, 6 subnets, NAT Gateway) | ✅ | Đã provision |
| EKS Cluster v1.33 (control plane + 2 node groups) | ✅ | Đã provision & verified |
| AWS Load Balancer Controller | ✅ | Cài qua Helm trong Terraform |
| Cert Manager | ✅ | Cài qua Helm trong Terraform |
| OTEL Operator (ADOT) | ✅ | EKS addon (collector disable) |
| ECR repositories | ⏳ | Chưa tạo |
| Staging/Prod environments | ⏳ | Chưa tạo |
| Scale node về 0 để tiết kiệm chi phí | ✅ | Sau khi verify thành công |

### Phase 3 & 4: CI+Security & CD+Observability — 0% (CHƯA BẮT ĐẦU)

---

## 2. Chi tiết kỹ thuật từng giai đoạn

### 2.1 Terraform Backend — Đã deploy

Quản lý Terraform state tập trung, tránh mất mát và conflict khi làm việc nhóm.

| Resource | ARN / ID |
|---|---|
| **S3 State Bucket** | `uit-devsecops-gitops-dev-0a502713-tfstate` |
| **DynamoDB Lock Table** | `uit-devsecops-gitops-dev-0a502713-tflock` |
| **AWS Region** | `ap-southeast-1` |
| **Encryption** | AES256 (server-side) |
| **Versioning** | Enabled |

```hcl
# Backend config (backend.hcl)
bucket         = "uit-devsecops-gitops-dev-0a502713-tfstate"
key            = "envs/dev/terraform.tfstate"
region         = "ap-southeast-1"
dynamodb_table = "uit-devsecops-gitops-dev-0a502713-tflock"
encrypt        = true
```

**Module sử dụng:** Custom (tự viết), 72 dòng Terraform.

**Giải thích cho báo cáo:**
- S3 bucket lưu `terraform.tfstate` — file mô tả toàn bộ tài nguyên đã tạo
- DynamoDB lock đảm bảo chỉ 1 người apply tại 1 thời điểm
- Versioning cho phép rollback state về phiên bản cũ nếu lỗi
- Block public access toàn bộ bucket để bảo mật

---

### 2.2 VPC — Đã provision

Mạng riêng ảo (VPC) là lớp mạng nền tảng, nơi tất cả tài nguyên sẽ hoạt động.

| Thông số | Giá trị |
|---|---|
| **VPC ID** | `vpc-0d37b4e9b21e95421` |
| **CIDR Block** | `10.0.0.0/16` |
| **Public Subnets** | 3 (mỗi subnet/24, 1 mỗi AZ) |
| **Private Subnets** | 3 (mỗi subnet/24, 1 mỗi AZ) |
| **NAT Gateway** | 1 (single, tiết kiệm chi phí) |
| **Internet Gateway** | `igw-089e9cb13e3af83dd` |
| **DNS Hostnames** | Enabled |

**Module sử dụng:** `terraform-aws-modules/vpc/aws` v5.21.0

**Giải thích cho báo cáo:**
- Private subnet dùng cho EKS worker nodes — không có IP public trực tiếp
- Public subnet dùng cho Load Balancer (ALB/NLB) — nhận traffic từ internet
- NAT Gateway cho phép private subnet truy cập internet (pull Docker images, gọi AWS API) nhưng bên ngoài không thể truy cập ngược vào
- Subnet tagging với `kubernetes.io/cluster` và `kubernetes.io/role` để EKS tự động nhận diện subnet nào dùng cho Load Balancer

---

### 2.3 EKS Cluster — Đã provision & verified

Kubernetes managed service trên AWS, tự động quản lý control plane.

| Thông số | Giá trị |
|---|---|
| **Cluster Name** | `uit-devsecops-dev` |
| **Kubernetes Version** | `v1.33.11` |
| **Control Plane Endpoint** | Public + Private |
| **OIDC Provider** | Đã tạo (cho IRSA) |
| **KMS Encryption** | Enabled (secrets encryption) |
| **Logging** | API, Audit, Authenticator → CloudWatch |

| Node Group | Instance | Min | Desired | Max | Subnet |
|---|---|---|---|---|---|
| `managed-nodegroup-1` | t3.medium | 0 | 0 | 1 | AZ 1 |
| `managed-nodegroup-2` | t3.medium | 0 | 0 | 1 | AZ 2 |

**Module sử dụng:**
- `terraform-aws-modules/eks/aws` ~> 19.9
- `aws-ia/eks-blueprints-addons/aws` ~> 1.0 (LB Controller + Cert Manager)

**Giải thích cho báo cáo:**
- EKS control plane do AWS quản lý — tự động HA, scale, cập nhật bảo mật
- Managed node groups dùng EC2 t3.medium (2 vCPU, 4GB RAM) — phù hợp cho đồ án
- KMS mã hóa Kubernetes secrets (etcd encryption)
- OIDC provider cho phép service accounts trong K8s gán IAM roles (IRSA — IAM Roles for Service Accounts) — nguyên lý bảo mật zero-trust
- Hiện đã scale node về 0 để tiết kiệm chi phí ngoài giờ làm việc

---

### 2.4 Kubernetes Addons — Đã deploy

| Addon | Namespace | Pods | Chức năng |
|---|---|---|---|
| **VPC-CNI** | — (managed) | 2x aws-node | Kết nối mạng cho pods, dùng ENI |
| **CoreDNS** | kube-system | 2 pods | DNS nội bộ trong cluster |
| **kube-proxy** | kube-system | 2 pods | Network proxy, quản lý Service |
| **AWS Load Balancer Controller** | kube-system | 2 pods | Tự động tạo ALB/NLB khi tạo K8s Service/Ingress |
| **Cert Manager** | cert-manager | 3 pods | Tự động cấp & renew TLS certificates |
| **OTEL Operator** | opentelemetry-operator-system | 1 pod | OpenTelemetry (collector disable, sẵn sàng Phase 4) |

---

### 2.5 Sample Application — Sẵn sàng deploy

Đã clone và phân tích `aws-containers/retail-store-sample-app`:

| Service | Language | Framework | DB / Backend |
|---|---|---|---|
| **UI** | Java 21 | Spring Boot + Thymeleaf | WebFlux API Gateway |
| **Cart** | Java 21 | Spring Boot | DynamoDB |
| **Orders** | Java 21 | Spring Boot | DynamoDB, SQS, SNS, Secrets Manager |
| **Catalog** | Go | Gin | MySQL / MariaDB |
| **Checkout** | TypeScript | NestJS 11 | Redis |

Tất cả các service đều có Dockerfile và docker-compose.yml sẵn sàng.

---

## 3. Kiến trúc tổng thể

```
Developer ──▶ GitHub App Repo ──▶ Jenkins CI ──▶ SonarQube + OWASP + Trivy
                                                    │
                                                    ▼ (push image)
                                              Amazon ECR
                                                    │
                                                    ▼ (update tag)
                                           GitHub GitOps Repo ──▶ Argo CD ──▶ EKS Cluster
                                                                   (pull & sync)   (uit-devsecops-dev)
```

```
┌──────────────────────────────────────────────────────┐
│                    AWS Infrastructure                  │
│                                                        │
│  VPC (10.0.0.0/16)                                     │
│  ├── Public Subnet × 3                                 │
│  │   └── Internet Gateway → ALB (public-facing)       │
│  ├── Private Subnet × 3                                │
│  │   ├── EKS Worker Nodes (t3.medium × 2)             │
│  │   └── NAT Gateway → Internet (pull images, API)    │
│  │                                                      │
│  ├── EKS Control Plane (v1.33)                         │
│  │   ├── VPC-CNI, CoreDNS, kube-proxy                  │
│  │   ├── AWS LB Controller                             │
│  │   ├── Cert Manager                                  │
│  │   └── OTEL Operator                                 │
│  │                                                      │
│  └── KMS + OIDC Provider + IRSA                        │
└──────────────────────────────────────────────────────┘
```

---

## 4. Kiểm thử & xác minh hệ thống

Sau khi `terraform apply` thành công, đã thực hiện các bước xác minh:

| Bước kiểm tra | Lệnh | Kết quả |
|---|---|---|
| **Kết nối cluster** | `kubectl cluster-info` | ✅ Control plane hoạt động |
| **Node status** | `kubectl get nodes` | ✅ 2 nodes, STATUS=Ready |
| **Tất cả pods** | `kubectl get pods -A` | ✅ 12 pods, tất cả Running |
| **Services** | `kubectl get svc -A` | ✅ 8 services, tất cả ClusterIP |
| **EKS Console** | AWS Console → EKS | ✅ Cluster status=Active |
| **VPC Console** | AWS Console → VPC | ✅ VPC + 6 subnets + NAT + IGW |
| **EC2 Console** | AWS Console → EC2 | ✅ 2 instances t3.medium running |
| **CloudWatch Logs** | AWS Console → CloudWatch | ✅ `/aws/eks/uit-devsecops-dev/cluster` đã tạo |

Phân tích kết quả `kubectl get pods -A`:

```
NAMESPACE     NAME                              READY   STATUS    RESTARTS
cert-manager  cert-manager-6c4645d66c-vn7th     1/1     Running   0
cert-manager  cert-manager-cainjector-...       1/1     Running   0
cert-manager  cert-manager-webhook-...          1/1     Running   0
kube-system   aws-load-balancer-controller-...   1/1     Running   0
kube-system   aws-load-balancer-controller-...   1/1     Running   0
kube-system   aws-node-s9glr                    2/2     Running   0
kube-system   aws-node-whlpn                    2/2     Running   0
kube-system   coredns-6cfd9cdcf-bmsc6           1/1     Running   0
kube-system   coredns-6cfd9cdcf-xbqv2           1/1     Running   0
kube-system   kube-proxy-5vcwh                  1/1     Running   0
kube-system   kube-proxy-pl9vf                  1/1     Running   0
opentelemetry opentelemetry-operator-...        2/2     Running   0
```

Tất cả 12 pods đều ở trạng thái Running, không có restart — cluster hoàn toàn khỏe mạnh.

---

## 5. Quản lý chi phí

### Phân tích chi phí dự kiến:

| Tài nguyên | Đơn giá | Tháng |
|---|---|---|
| EKS Control Plane | $0.10/giờ | ~$72 |
| 2 × t3.medium (khi chạy) | $0.0528/giờ/node | ~$76 |
| NAT Gateway | $0.045/giờ | ~$32 |
| **Tổng (full-time)** | | **~$180/tháng** |
| **Tổng (node off, chỉ control plane)** | | **~$104/tháng** |

### Chiến lược tiết kiệm đã triển khai:

1. **Node groups scale về 0** ngoài giờ làm: giảm $76/tháng
2. **Single NAT Gateway** (thay vì 3): giảm 2/3 chi phí NAT
3. **Không dùng Istio** service mesh
4. **Không dùng OpenTelemetry collector**
5. **Tài khoản AWS mới** — tận dụng Free Tier EC2, S3, CloudWatch
6. Sẵn sàng dùng `terraform destroy` khi nghỉ dài ngày → $0

**File cấu hình tiết kiệm:** `03-infra/terraform/envs/dev/terraform.tfvars`

---

## 6. Kế hoạch tiếp theo

| # | Công việc | Dự kiến | Ưu tiên |
|---|---|---|---|
| 1 | Tạo ECR repositories cho 5 microservice | Tuần tới | Cao |
| 2 | Viết Jenkinsfile: build → test → scan → push ECR | Tuần tới | Cao |
| 3 | Tích hợp SonarQube SAST vào pipeline | Tuần tới | Cao |
| 4 | Tích hợp OWASP Dependency Check | Tuần tới | Trung bình |
| 5 | Tích hợp Trivy image scan | Tuần tới | Trung bình |
| 6 | Viết Kustomize manifests (base + dev overlay) | Tuần sau | Cao |
| 7 | Cài đặt & cấu hình Argo CD | Tuần sau | Cao |
| 8 | Auto-update GitOps repo image tag (CI bot commit) | Tuần sau | Trung bình |
| 9 | Demo deploy toàn bộ app lên EKS | Tuần sau | Cao |
| 10 | Demo rollback bằng git revert | Tuần sau | Cao |
| 11 | Cài đặt CloudWatch + Prometheus + Grafana | Phase 4 | Thấp |
| 12 | Viết runbooks & alerts | Phase 4 | Thấp |
| 13 | Tổng hợp evidence, viết báo cáo cuối kỳ | Cuối kỳ | Cao |

---

## 7. Rủi ro & cách kiểm soát

| Rủi ro | Mức độ | Biện pháp |
|---|---|---|
| **IAM permission hạn chế** | Đã xử lý ✅ | Đã gán AdministratorAccess cho user |
| **Chi phí AWS vượt ngân sách** | Đã kiểm soát ✅ | Scale node về 0, single NAT, dùng free tier |
| **EKS provisioning lâu (~15 phút)** | Thấp | Terraform tự động hóa hoàn toàn, không cần can thiệp thủ công |
| **Quên tắt tài nguyên** | Trung bình | Đã tạo script shutdown (`terraform apply` với node=0), state lưu S3 |
| **Phiên bản module không tương thích** | Thấp | Dùng version pinning cụ thể, không dùng `latest` |

---

## Ghi chú gửi GVHD

1. **Tất cả infrastructure đã được quản lý 100% bằng Terraform** — không có tài nguyên nào được tạo thủ công, đảm bảo tính tái lập (reproducible) và nhất quán giữa các môi trường.

2. **Terraform state lưu trên S3** với versioning và lock — đảm bảo an toàn dữ liệu và hỗ trợ làm việc nhóm sau này.

3. **Đã verify cluster hoạt động đúng** — control plane, worker nodes, DNS, networking, addons đều hoạt động bình thường.

4. **Đề xuất buổi gặp tiếp theo:** demo trực tiếp Terraform apply EKS cluster (từ 0 đến Ready trong ~13 phút), sau đó demo deploy sample app đầu tiên lên cluster.
