# DANH SÁCH SỬA ĐỔI — Đối chiếu báo cáo DOCX (11/06/2026)

## THAY ĐỔI QUAN TRỌNG NHẤT

### 1. LB Controller — không còn CrashLoopBackOff
- **Vị trí:** Mục 4.1.2 (output kubectl get pods), Mục 5.3 (Hạn chế)
- **Cũ:** `0/1 CrashLoopBackOff`, "NLB restriction"
- **Mới:** `1/1 Running`, **XÓA** ghi chú về NLB restriction

### 2. ALB hoạt động — Argo CD có public URL
- **Vị trí:** Mục 4.4, Mục 5.3
- **Mới:** Argo CD expose qua AWS ALB Ingress, URL: `k8s-argocd-argocdin-xxx.elb.amazonaws.com`
- Không cần port-forward

### 3. Tổng pods: 32 → 41
- **Vị trí:** Mục 4.1.2, Evidence E02
- Thêm: Kyverno (4), SonarQube (2), catalog-db MySQL (1), Jenkins custom

### 4. Node groups: 2 → 3
- **Vị trí:** Mục 4.1.1, Mục 4.1.3, Evidence E03
- Mới: 2× t3.medium + 1× t3.large (managed-ng-large)

---

## ĐÃ LÀM THÊM (TỪ 4.6 TRỞ ĐI)

### Mục 4.6 — Kyverno Policy as Code (MỚI HOÀN TOÀN)
- 5 ClusterPolicies: disallow-root, require-probes, require-limits, disallow-latest-tag, require-labels
- Chế độ Audit
- Policy Reports tự động

### Mục 4.7 — Terrascan + Checkov IaC Scan (MỚI HOÀN TOÀN)
- Terrascan: 1 LOW (vpcFlowLogsNotEnabled — cố ý tắt cho dev)
- Checkov: 3 PASSED, 3 FAILED (CKV_TF_1 - module version not pinned to commit hash)
- Report JSON có trong `06-security/scan-reports/`

### Mục 4.8 — SAST + SCA + Container Scan (MỚI HOÀN TOÀN)

**SonarQube SAST (Gate 1):**
- Scan thật cart service: 100 files, 5 languages (Java, XML, YAML, JSON, Docker)
- Quality profile: Sonar way
- Report uploaded: `dashboard?id=retail-store-cart`

**OWASP DC SCA (Gate 2):**
- Tool v12.1.0, NVD database 350MB+ downloaded
- Scan cart dependencies (Maven)

**Trivy Image Scan (Gate 3):**
- Scan cart image từ ECR
- Phát hiện 4 CVE: CVE-2023-20873 (Spring Boot), CVE-2016-1000027 (Spring Web), CVE-2023-20860 (Spring WebMVC), CVE-2023-0833 (OkHttp)

**Kaniko Build:**
- Build thật từ git source bằng Kaniko (211s)
- Image: `uit-devsecops-dev-cart:kaniko-built`
- Push ECR thành công

### Mục 4.9 — Jenkins CI Pipeline (CẬP NHẬT)
- Jenkins deploy từ custom Docker image trên ECR (`uit-devsecops-dev-jenkins:latest`)
- Image chứa sẵn: Trivy 0.71, OWASP DC 12.1, SonarScanner 6.2
- Không cần cài tool thủ công, không lo mất khi restart

### Mục 4.10 — Argo CD ALB Ingress (CẬP NHẬT)
- LB Controller tự động tạo ALB từ Ingress resource
- Public URL: `k8s-argocd-argocdin-53ad2a099b-2141731615.ap-southeast-1.elb.amazonaws.com`
- Argo CD truy cập qua HTTP (không cần port-forward)

---

## THAY ĐỔI Ở CÁC MỤC TRƯỚC 4.6

| Mục | Thay đổi |
|-----|---------|
| 4.1.2 | Pods: 32 → 41. LB Controller: CrashLoopBackOff → Running. Catalog pods có kèm MySQL. |
| 4.1.3 | Node groups: 2 → 3. EC2: 2 nodes → 3 nodes. |
| 4.3 | Jenkins deploy từ custom image có sẵn tool. Kaniko build đã kiểm thử. |
| 4.4 | Argo CD có ALB public URL. Ingress tự động provision. |
| 4.5 | App pods: 6 → 7 (thêm catalog-db MySQL). Catalog chạy ổn định. |

---

## THAY ĐỔI CHƯƠNG 5

### 5.1 — Kết quả đạt được
- Thêm: SonarQube SAST, OWASP DC SCA, Trivy scan — cả 3 đã thực thi
- Thêm: Terrascan + Checkov IaC scan
- Thêm: Kaniko build thành công
- Thêm: ALB public cho Argo CD
- Thêm: Restore script (2 lệnh khôi phục toàn bộ)

### 5.3 — Hạn chế
- **XÓA:** "LB Controller CrashLoopBackOff do NLB restriction"
- **XÓA:** "Argo CD ALB cũ vẫn hoạt động" → "ALB tạo mới hoạt động bình thường"
- **XÓA:** "CI pipeline chưa triển khai" → CI đã chạy đầy đủ
- **XÓA:** "Security scanning sẵn sàng tích hợp" → đã thực thi có kết quả
- **THÊM:** Catalog cần MySQL (đã deployed), AWS NLB vẫn bị hạn chế (ALB không bị)

### 5.4 — Hướng phát triển
- **XÓA:** "Triển khai đầy đủ CI/CD pipeline" (đã xong)
- **THÊM:** HTTPS + ACM certificate cho ALB
- **THÊM:** Multi-cluster GitOps

---

## PHỤ LỤC

### Evidence Checklist — Items mới
- **E10:** Kyverno ClusterPolicies + Policy Reports (`phase-4-security/`)
- **E11:** Terrascan scan report (`phase-4-security/`)
- **E12:** Checkov scan report (`phase-4-security/`)
- **E13:** ALB Ingress proof — Argo CD public URL (`phase-4-alb/`)

### Cập nhật evidence cũ
- E02: "32 pods" → "41 pods"
- E03: "2 node groups" → "3 node groups", "2 instances" → "3 instances"
- E04: thêm "Shared Libraries 6 hàm Groovy"
- E05: thêm "Helm chart + Argo CD Ingress ALB"
- E06: thêm "12 Prometheus rules"
- E07: thêm "7 pods retail-store (có MySQL)"

---

## BẢNG CON SỐ TỔNG HỢP

| Thông số | Cũ | Mới |
|----------|----|-----|
| Node groups | 2 | 3 |
| EC2 instances | 2 t3.medium | 2 t3.medium + 1 t3.large |
| Tổng pods cluster | 32 | 41 |
| LB Controller | CrashLoopBackOff | Running |
| Argo CD access | port-forward | ALB public URL |
| Security gates | designed only | executed + results |
| SonarQube | deployed | deployed + scanned 100 files |
| Trivy | deployed | scanned + 4 CVEs found |
| OWASP DC | deployed | NVD DB + scan |
| Kaniko | claimed blocked | build success (211s) |
| Terrascan | upstream code | project code |
| Checkov | none | 3 passed, 3 failed |
| Kyverno | YAML only | deployed on cluster |
| Prometheus alerts | 10 | 12 rules deployed |
| MySQL catalog | none | deployed + working |
| Jenkins tools | manual install | baked in Docker image |
| Restore | N/A | 2 commands |

---

## LƯU Ý KHI CẬP NHẬT DOCX

1. **Từ mục 4.6 trở đi hoàn toàn mới** — cần viết thêm section
2. Các mục trước 4.6 có sửa số liệu (pods, nodes, LB Controller)
3. Chương 5 cần viết lại hoàn toàn phần Hạn chế + Hướng phát triển
4. Phụ lục thêm E10-E13
5. Không còn claim nào về "NLB restriction" hay "LB Controller lỗi"
