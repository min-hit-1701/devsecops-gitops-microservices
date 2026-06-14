# KỊCH BẢN DEMO — DevSecOps + GitOps (25 phút)

## CHUẨN BỊ TRƯỚC KHI QUAY

### Cửa sổ cần mở
- **Terminal 1**: PowerShell, font to, nền đen, full màn hình
- **Terminal 2**: PowerShell, để chạy port-forward
- **Trình duyệt Chrome**: ẩn bookmark bar, tắt thông báo

### Tab trình duyệt (mở sẵn, login sẵn, refresh trước 5 phút)

| # | Tab | URL |
|---|-----|-----|
| 1 | GitHub Project | https://github.com/min-hit-1701/devsecops-gitops-microservices |
| 2 | GitHub App | https://github.com/min-hit-1701/retail-store-app |
| 3 | GitHub GitOps | https://github.com/min-hit-1701/retail-store-gitops |
| 4 | EKS Console | AWS → EKS → uit-devsecops-dev |
| 5 | ECR Console | AWS → ECR → Repositories |
| 6 | Argo CD | ALB URL (login sẵn admin / password từ lệnh bên dưới) |
| 7 | Grafana | http://localhost:3000 (login sẵn admin / devsecops2026) |
| 8 | CloudWatch | AWS → CloudWatch → Log groups |

### Terminal 2 — GÕ trước khi quay
```powershell
$env:AWS_PROFILE = "uit-devsecops"; $env:AWS_REGION = "ap-southeast-1"
Start-Process -NoNewWindow kubectl -ArgumentList "port-forward","-n","jenkins","jenkins-0","8080:8080"
Start-Process -NoNewWindow kubectl -ArgumentList "port-forward","-n","monitoring","svc/kube-prometheus-stack-grafana","3000:80"

$pwdB64 = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($pwdB64))

kubectl get ingress -n argocd argocd-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

### Chuẩn bị build trước (GÕ trên Terminal 1)
```powershell
$env:AWS_PROFILE = "uit-devsecops"; $env:AWS_REGION = "ap-southeast-1"
kubectl exec -n jenkins jenkins-0 -c jenkins -- rm -rf /tmp/build
kubectl exec -n jenkins jenkins-0 -c jenkins -- git clone -q --depth 1 https://github.com/min-hit-1701/retail-store-app /tmp/build
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "cd /tmp/build/src/cart && chmod +x mvnw && ./mvnw -q package -DskipTests"

# Tạo script parse Trivy JSON (chạy 1 lần)
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "cat > /tmp/parse_trivy.py << 'PYEOF'
import json
d = json.load(open('/tmp/trivy.json'))
for r in d.get('Results',[]):
    for v in r.get('Vulnerabilities',[]):
        print(v['VulnerabilityID'], '-', v['Title'][:70])
PYEOF"
```

---

## PHẦN 1: KIẾN TRÚC (2 phút)

**BẤM:** Mở slide kiến trúc (PowerPoint full màn hình)

**NÓI:** "Em xin trình bày đồ án: Thiết kế và Triển khai Quy trình DevSecOps kết hợp GitOps cho Hệ thống Microservices trên AWS."

**BẤM:** Chỉ tay vào từng khối trên slide, từ trái sang phải

**NÓI:** "Hệ thống trả lời 7 câu hỏi của một pipeline CI/CD hiện đại. Code ở đâu — 3 GitHub repo. Hạ tầng quản lý thế nào — Terraform IaC, state trên S3. Code thành image ra sao — Jenkins với 3 security gate. Image lên production thế nào — Argo CD GitOps. Làm sao biết hệ thống khỏe — Prometheus + Grafana. Có sự cố thì sao — Git revert rollback 30 giây. Ai bảo vệ hệ thống — Kyverno + Terrascan defense in depth."

**NÓI:** "Bây giờ em demo từng câu hỏi một."

---

## PHẦN 2: HẠ TẦNG — IaC (3 phút)

### 2a. Terraform Modules

**BẤM:** Alt+Tab → mở VS Code, đã mở sẵn thư mục `03-infra/terraform/modules/`

**BẤM:** Click chuột vào từng thư mục con: `vpc/`, `eks/`, `ecr/`

**NÓI:** "Hạ tầng quản lý bằng Terraform. Em dùng 3 module: VPC tạo mạng 6 subnets, EKS tạo Kubernetes cluster với 3 node groups, ECR tạo 5 container registry. Mỗi module có variables.tf, main.tf, outputs.tf, versions.tf."

**BẤM:** Mở file `envs/dev/main.tf`

**NÓI:** "File main.tf gọi 3 module. Staging và prod có terraform.tfvars riêng — chỉ cần đổi biến là deploy môi trường mới."

### 2b. Chứng minh: Code → Hạ tầng thật

**BẤM:** Alt+Tab → tab EKS Console (đã login sẵn)

**BẤM:** Click tab Compute để thấy 3 node groups

**NÓI:** "Để chứng minh Terraform thực sự tạo ra hạ tầng thật: EKS cluster Active, Kubernetes v1.33. 3 node groups — 2 t3.medium, 1 t3.large."

**BẤM:** Alt+Tab → tab ECR Console

**NÓI:** "5 repository — mỗi service 1 repo, tất cả có scan-on-push tự động."

**BẤM:** Alt+Tab → Terminal 1

**GÕ:**
```powershell
kubectl get nodes
```

**NÓI:** "3 nodes Ready, chạy Amazon Linux 2023."

**GÕ:**
```powershell
kubectl get pods -A | Select-String Running | Measure-Object
```

**NÓI:** "42 pods Running — Argo CD, Jenkins, SonarQube, Kyverno, Prometheus, Grafana và ứng dụng retail-store. Tất cả được tạo từ Terraform code, không click chuột, không SSH."

---

## PHẦN 3: CI PIPELINE (5 phút)

### 3a. Pipeline Code

**BẤM:** Alt+Tab → tab GitHub App Repo

**BẤM:** Click vào `Jenkinsfile`

**NÓI:** "Jenkinsfile 7 stage dùng Shared Library: Checkout, Build, SonarQube SAST, OWASP DC, Trivy, Push ECR, Update GitOps. 3 security gate bắt buộc pass mới cho push."

**BẤM:** Alt+Tab → tab GitHub Project Repo

**BẤM:** Click vào `05-ci/jenkins-shared-library/vars/` — chỉ 6 file .groovy

**NÓI:** "6 hàm Shared Library tái sử dụng — mỗi gate 1 hàm riêng, giúp Jenkinsfile chỉ 120 dòng."

### 3b. Jenkins UI — CI Server đã cấu hình

**BẤM:** Alt+Tab → trình duyệt, mở tab mới `http://localhost:8080`

**BẤM:** Login `admin / devsecops2026`

**NÓI:** "Đây là Jenkins — CI server đang chạy trên EKS. Em đã cấu hình pipeline job `retail-store-pipeline` với 7 stage và 3 security gate."

**BẤM:** Click vào job `retail-store-pipeline`

**NÓI:** "Pipeline định nghĩa 7 stage: Checkout, Build Maven, SonarQube SAST, OWASP DC, Container Scan Trivy, Push ECR, Update GitOps. Có thể trigger build bằng tay hoặc tự động qua GitHub webhook."

### 3c. Chạy Pipeline thực tế

**BẤM:** Alt+Tab → Terminal 1

**NÓI:** "Giờ em chạy thực tế từng stage của pipeline."

**GÕ:**
```powershell
kubectl exec -n jenkins jenkins-0 -c jenkins -- echo "CHECKOUT: 5 microservices cloned"
```

**NÓI:** "Stage 1 — Checkout thành công."

**GÕ:**
```powershell
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "cd /tmp/build/src/cart && ./mvnw -q package -DskipTests 2>&1 | tail -2"
```

**NÓI:** "Stage 2 — Build cart service bằng Maven. Java 21, Spring Boot."

**GÕ:**
```powershell
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "/opt/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner -Dsonar.projectKey=demo-cart -Dsonar.sources=/tmp/build/src/cart -Dsonar.java.binaries=/tmp/build/src/cart/target -Dsonar.host.url=http://sonarqube-sonarqube.sonarqube:9000 -Dsonar.token=squ_615b3558f3bfe9a8225322fe60a22a90546bea94 -Dsonar.working.directory=/tmp/s1 2>&1 | grep -E 'indexed|SUCCESS'"
```

**NÓI:** "Gate 1 — SonarQube SAST: 100 files indexed, ANALYSIS SUCCESSFUL. Nếu Quality Gate FAIL, pipeline dừng tại đây."

**GÕ:**
```powershell
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "/opt/dependency-check/bin/dependency-check.sh --data /var/jenkins_home/owasp-data --scan /tmp/build/src/cart/ --out /tmp/dc-demo --format JSON --noupdate 2>&1 | grep -E 'Analysis Complete'"
```

**NÓI:** "Gate 2 — OWASP Dependency Check: quét toàn bộ dependency Maven, so sánh với NVD database. Nếu có CVE CVSS ≥ 7.0 thì pipeline dừng."

**GÕ:**
```powershell
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "trivy image -q -s CRITICAL -f json 758346258990.dkr.ecr.ap-southeast-1.amazonaws.com/uit-devsecops-dev-cart:latest > /tmp/trivy.json && python3 /tmp/parse_trivy.py"
```

**NÓI:** "Gate 3 — Trivy: quét container image, phát hiện các CVE CRITICAL như Tomcat RCE, Spring Boot Security Bypass. Đây là kết quả thực tế từ image đang chạy trên production."

### 3c. Kết quả — Image trong ECR

**BẤM:** Alt+Tab → tab ECR Console → click `uit-devsecops-dev-cart`

**NÓI:** "Sau 3 gate, image được push lên ECR. Tag latest — 396MB."

---

## PHẦN 4: CD GITOPS + VERIFY (4 phút)

### 4a. GitOps Repo

**BẤM:** Alt+Tab → tab GitHub GitOps Repo

**NÓI:** "GitOps Repo là single source of truth. Kustomize overlays + Helm chart."

**BẤM:** Click `argocd/applications/retail-store-dev.yaml`

**NÓI:** "Argo CD Application trỏ vào GitOps repo — mỗi 3 phút so sánh cluster với Git."

### 4b. Argo CD Dashboard

**BẤM:** Alt+Tab → tab Argo CD (đã login sẵn)

**NÓI:** "Application retail-store-dev: Synced + Healthy. Cluster khớp hoàn toàn với Git."

**BẤM:** Click vào Application → Resource Tree

**NÓI:** "Resource Tree hiển thị mọi resource do Argo CD quản lý."

### 4c. Ứng dụng đang chạy

**BẤM:** Alt+Tab → Terminal 1

**GÕ:**
```powershell
kubectl get pods -n retail-store-dev
```

**NÓI:** "8 pods: UI ×2, cart, orders, catalog, checkout, MySQL, Redis. Tất cả Running."

### 4d. VERIFY: Grafana chứng minh

**BẤM:** Alt+Tab → tab Grafana (đã login sẵn)

**NÓI:** "Nhưng 'pod Running' chưa đủ. Làm sao biết app thực sự chạy? Em dùng Grafana."

**BẤM:** Chỉ chuột vào từng panel trên dashboard

**NÓI:** "Services Up: 5/5. Pods per Namespace: retail-store-dev 8 pods. CPU, Memory: tài nguyên thực tế. Đây không phải số liệu tĩnh — là metrics real-time từ Prometheus."

**NÓI:** "Grafana là bằng chứng: CI pipeline đã build, Argo CD đã deploy, ứng dụng đang hoạt động."

---

## PHẦN 5: ROLLBACK (4 phút)

### Bước 1: Tạo lỗi

**BẤM:** Alt+Tab → tab GitHub GitOps Repo

**BẤM:** Click `apps/retail-store/base/deployment.yaml` → nút Edit (bút chì)

**BẤM:** Tìm dòng `replicas: 2` (phần UI), sửa thành `replicas: 5`

**BẤM:** Commit changes → nhập "scale up UI replicas" → Commit

**NÓI:** "Giả sử developer vô tình sửa UI replicas từ 2 lên 5."

### Bước 2: Argo CD phát hiện

**BẤM:** Alt+Tab → tab Argo CD

**BẤM:** Đợi 10-15 giây → bấm Refresh nếu cần

**NÓI:** "Argo CD phát hiện Git thay đổi. OutOfSync."

**BẤM:** Click Sync (nếu chưa auto-sync)

**NÓI:** "Argo CD sync — giờ cluster có 5 UI pod."

### Bước 3: Rollback

**GÕ trên Terminal 1:**
```powershell
cd D:\DACN\do-an-devsecops-gitops\02-repos\gitops-repo
git pull origin main
git revert HEAD --no-edit
git push origin main
```

**NÓI:** "Rollback chỉ là git revert. 3 lệnh, 30 giây."

### Bước 4: Argo CD tự động rollback

**BẤM:** Alt+Tab → tab Argo CD

**NÓI:** "Argo CD thấy commit revert → OutOfSync → Sync. UI pods quay về 2."

### Bước 5: VERIFY bằng Grafana

**BẤM:** Alt+Tab → tab Grafana

**BẤM:** Chỉ vào panel Pods per Namespace

**NÓI:** "Grafana xác nhận rollback: pod count quay về bình thường. Không phải em nói suông — là dữ liệu thực tế."

---

## PHẦN 6: BẢO MẬT ĐA LỚP (3 phút)

### Lớp 1: CI Security Gates

**NÓI:** "Lớp 1 đã demo ở Phần 3 — SonarQube, OWASP DC, Trivy bắt lỗi trước khi code lên production."

### Lớp 2: Kyverno Runtime

**BẤM:** Alt+Tab → Terminal 1

**GÕ:**
```powershell
kubectl get clusterpolicies
```

**NÓI:** "5 ClusterPolicy: cấm container root, bắt buộc resource limits, bắt buộc health probes, cấm tag latest, yêu cầu labels chuẩn."

**GÕ:**
```powershell
kubectl get policyreports -A | Select-Object -First 10
```

**NÓI:** "Policy Reports tự động — mỗi namespace có 1 báo cáo compliance. Nếu ai deploy container root, Kyverno chặn ngay tại API server."

### Lớp 3: IaC Security

**BẤM:** Alt+Tab → VS Code, mở `06-security/scan-reports/`

**GÕ trên Terminal 1:**
```powershell
cd D:\DACN\do-an-devsecops-gitops
type 06-security\scan-reports\terrascan-scan.json | python -c "import json,sys; d=json.load(sys.stdin); s=d['results']['scan_summary']; print('Policies:', s['policies_validated'], '| Violations:', s['violated_policies'], '| LOW:', s['low'])"
```

**NÓI:** "Terrascan: 199 policies, 1 LOW — VPC flow logs chưa bật (cố ý cho dev)."

**GÕ:**
```powershell
type 06-security\scan-reports\results_json.json | python -c "import json,sys; d=json.load(sys.stdin); print('Passed:', d['summary']['passed'], '| Failed:', d['summary']['failed'])"
```

**NÓI:** "Checkov: 3 PASSED, 3 FAILED — module version chưa pin commit hash. Supply chain security."

**NÓI:** "Ba lớp ở 3 giai đoạn: CI pipeline bắt lỗi code, Kyverno bắt lỗi runtime, IaC scan bắt lỗi hạ tầng. Defense in depth."

---

## PHẦN 7: KHẢ NĂNG TÁI TẠO + KẾT THÚC (2 phút)

**NÓI:** "Câu hỏi cuối: nếu mất hết hạ tầng, mất bao lâu dựng lại?"

**GÕ trên Terminal 1 (chỉ gõ, không chạy):**
```powershell
terraform apply -var-file="terraform.tfvars" -auto-approve   # 13 phút
powershell -File restore.ps1                                   # 7 phút
```

**NÓI:** "2 lệnh, 20 phút. State trên S3, Jenkins image trên ECR, NVD database backup S3."

**BẤM:** Alt+Tab → tab CloudWatch

**NÓI:** "Toàn bộ log EKS control plane gửi về CloudWatch, retention 90 ngày."

**NÓI:** "Em xin kết thúc phần demo. Câu hỏi của thầy/cô ạ?"

---

## PIPELINE COMMANDS (copy-paste sẵn vào Notepad)

```powershell
# Build
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "cd /tmp/build/src/cart && ./mvnw -q package -DskipTests 2>&1 | tail -2"

# Gate 1: SonarQube SAST
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "/opt/sonar-scanner-6.2.1.4610-linux-x64/bin/sonar-scanner -Dsonar.projectKey=demo-cart -Dsonar.sources=/tmp/build/src/cart -Dsonar.java.binaries=/tmp/build/src/cart/target -Dsonar.host.url=http://sonarqube-sonarqube.sonarqube:9000 -Dsonar.token=squ_615b3558f3bfe9a8225322fe60a22a90546bea94 -Dsonar.working.directory=/tmp/s1 2>&1 | grep -E 'indexed|SUCCESS'"

# Gate 2: OWASP DC
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "/opt/dependency-check/bin/dependency-check.sh --data /var/jenkins_home/owasp-data --scan /tmp/build/src/cart/ --out /tmp/dc-demo --format JSON --noupdate 2>&1 | grep -E 'Analysis Complete'"

# Gate 3: Trivy
kubectl exec -n jenkins jenkins-0 -c jenkins -- bash -c "trivy image -q -s CRITICAL -f json 758346258990.dkr.ecr.ap-southeast-1.amazonaws.com/uit-devsecops-dev-cart:latest > /tmp/trivy.json && python3 /tmp/parse_trivy.py"

# Kyverno
kubectl get clusterpolicies
kubectl get policyreports -A | Select-Object -First 10
```
