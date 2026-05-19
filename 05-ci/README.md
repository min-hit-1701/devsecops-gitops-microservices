# DevSecOps CI Pipeline — Setup Guide

## Tong quan

CI Pipeline duoc xay dung tren Jenkins voi 3 security gates:
1. **SonarQube SAST** — Phan tich ma nguon tinh
2. **OWASP Dependency Check** — Kiem tra lo hong trong dependency
3. **Trivy Image Scan** — Quet Docker image

Chi artifact vuot qua ca 3 gate moi duoc push len ECR va deploy.

## Prerequisites

### 1. Jenkins Server
- Jenkins 2.400+ cai tren EC2 (t3.medium, Amazon Linux 2023)
- Cai plugin:
  - `Pipeline` (mac dinh)
  - `Git`
  - `SonarQube Scanner`
  - `Docker Pipeline`
  - `SSH Agent`
  - `Credentials Binding`
  - `Blue Ocean` (optional, UI dep hon)

### 2. SonarQube Server
- SonarQube 10.x cai tren EC2 hoac Docker
- Tao project `uit-devsecops-retail-store`
- Tao Quality Gate `DevSecOps Security Gate` (xem `security-gates/sonarqube-quality-gate.yml`)
- Tao token cho Jenkins → luu trong Jenkins Credentials

### 3. Cong cu tren Jenkins agent
- **Docker** — build & push images
- **AWS CLI** — ECR login
- **Trivy** — container image scan
  ```bash
  wget https://github.com/aquasecurity/trivy/releases/download/v0.50.0/trivy_0.50.0_Linux-64bit.deb
  sudo dpkg -i trivy_0.50.0_Linux-64bit.deb
  ```
- **OWASP Dependency Check**
  ```bash
  wget https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.0/dependency-check-9.0.0-release.zip
  unzip dependency-check-9.0.0-release.zip -d /opt/
  ```
- **SonarQube Scanner**
  ```bash
  wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
  unzip sonar-scanner-cli-5.0.1.3006-linux.zip -d /opt/
  ```
- **Python 3** (cho script update GitOps repo)
  ```bash
  pip3 install pyyaml
  ```

### 4. Jenkins Credentials
Cau hinh trong Manage Jenkins > Credentials:
- `OWASP_NVD_API_KEY` — API key tu NVD (https://nvd.nist.gov/developers/request-an-api-key)
- `gitops-deploy-key` — SSH private key co quyen push vao GitOps repo
- `SonarQube Token` — Token tu SonarQube server

### 5. AWS IAM Permissions
Jenkins agent can quyen:
- `AmazonEC2ContainerRegistryPowerUser` — push/pull ECR
- Policy inline cho `ecr:GetAuthorizationToken`

## Pipeline Flow

```
Git Push → Jenkins Webhook
  |
  +- Stage 1: Checkout code tu App Repo
  +- Stage 2: Build (parallel) — Maven/Go/Yarn
  +- Stage 3: SonarQube SAST → Quality Gate
  +- Stage 4: OWASP Dependency Check → CVSS threshold
  +- Stage 5: Docker Build (parallel) — 5 images
  +- Stage 6: Trivy Image Scan → CRITICAL check
  +- Stage 7: Push to ECR (parallel)
  +- Stage 8: Update GitOps Repo → Argo CD sync
```

## File Structure

```
05-ci/
  jenkins/
    Jenkinsfile              # Pipeline chinh (declarative)
    update-gitops-repo.py    # Script Python cap nhat GitOps repo
    docker-build.sh          # Script build Docker thủ công
    README.md                # File nay
  security-gates/
    sonarqube-quality-gate.yml  # Cấu hình Quality Gate
    owasp-threshold.yml         # Threshold cho OWASP DC
    trivy-policy.yml            # Policy cho Trivy scan
```

## Cach chay Pipeline

### Auto trigger (Webhook)
1. Cau hinh GitHub Webhook → Jenkins URL
2. Webhook fire khi push vao App Repo

### Manual trigger
1. Vao Jenkins → Retail Store Pipeline → Build with Parameters
2. Chon branch, image tag (optional)
3. Build

## Kiem tra Security Gate

### SonarQube
```
http://<sonarqube-server>:9000/dashboard?id=uit-devsecops-retail-store
```
Kiem tra Quality Gate status (PASS/FAIL)

### OWASP Dependency Check
Report: `dependency-check-report/dependency-check-report.html`
Kiem tra cac dependency co CVSS >= 7.0

### Trivy
Report: `trivy-report-<service>.json` (archived trong Jenkins artifacts)
Kiem tra CRITICAL vulnerabilities

## Troubleshooting

### Loi: SonarQube Quality Gate FAILED
→ Mo SonarQube dashboard, xem issues, fix code, push lai

### Loi: OWASP DC found HIGH CVE
→ Kiem tra report, neu la false positive → them vao `owasp-suppressions.xml`

### Loi: Trivy found CRITICAL CVE  
→ Kiem tra image base, update base image version

### Loi: ECR login failed
→ Kiem tra AWS credentials tren Jenkins agent
→ `aws sts get-caller-identity`

### Loi: GitOps repo push failed
→ Kiem tra SSH key da duoc add vao GitHub repo
→ Kiem tra quyen write tren GitOps repo
