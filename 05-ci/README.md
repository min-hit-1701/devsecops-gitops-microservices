# DevSecOps CI Pipeline — Setup Guide

## Overview

The CI Pipeline is built on Jenkins with 3 security gates:
1. **SonarQube SAST** — Static source code analysis
2. **OWASP Dependency Check** — Vulnerability scanning in dependencies
3. **Trivy Image Scan** — Docker image scanning

Only artifacts that pass all 3 gates are pushed to ECR and deployed.

## Prerequisites

### 1. Jenkins Server
- Jenkins 2.400+ installed on EC2 (t3.medium, Amazon Linux 2023)
- Install plugins:
  - `Pipeline` (default)
  - `Git`
  - `SonarQube Scanner`
  - `Docker Pipeline`
  - `SSH Agent`
  - `Credentials Binding`
  - `Blue Ocean` (optional, prettier UI)

### 2. SonarQube Server
- SonarQube 10.x installed on EC2 or Docker
- Create project `uit-devsecops-retail-store`
- Create Quality Gate `DevSecOps Security Gate` (see `security-gates/sonarqube-quality-gate.yml`)
- Create token for Jenkins → store in Jenkins Credentials

### 3. Tools on Jenkins Agent
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
- **Python 3** (for GitOps repo update script)
  ```bash
  pip3 install pyyaml
  ```

### 4. Jenkins Credentials
Configure in Manage Jenkins > Credentials:
- `aws-credentials` — AWS IAM credentials (type: **AWS Credentials**). Uses the CloudBees AWS Credentials plugin — no account ID is hardcoded in the pipeline. See: https://plugins.jenkins.io/aws-credentials/
- `OWASP_NVD_API_KEY` — API key from NVD (https://nvd.nist.gov/developers/request-an-api-key)
- `gitops-deploy-key` — SSH private key with push access to the GitOps repo

### 5. AWS IAM Permissions
The AWS IAM user (stored in `aws-credentials`) must have:
- `AmazonEC2ContainerRegistryPowerUser` — push/pull ECR
- `AmazonEKSClusterPolicy` — EKS access (for future kubeconfig integration)

### 6. How AWS Authentication Works
No account ID or secret keys are hardcoded in the Jenkinsfile. Instead:
1. The **CloudBees AWS Credentials Plugin** stores IAM credentials securely
2. `withAWS(credentials: 'aws-credentials', region: 'ap-southeast-1')` injects them at runtime
3. Account ID is resolved dynamically via `aws sts get-caller-identity`
4. ECR authentication uses the **Amazon ECR Plugin**: `docker.withRegistry("https://<url>", "ecr:<region>:<credentials-id>")`

## Pipeline Flow

```
Git Push → Jenkins Webhook
  |
  +- Stage 0: AWS Setup (resolve account ID, no hardcoded values)
  +- Stage 1: Checkout code from App Repo
  +- Stage 2: Build (parallel) — Maven/Go/Yarn
  +- Stage 3: SonarQube SAST → Quality Gate
  +- Stage 4: OWASP Dependency Check → CVSS threshold
  +- Stage 5: Docker Build → Trivy Scan → Push ECR (integrated)
  +- Stage 6: Update GitOps Repo → Argo CD auto-sync
```

## File Structure

```
05-ci/
  jenkins/
    Jenkinsfile              # Main pipeline (declarative)
    update-gitops-repo.py    # Python script to update GitOps repo
    docker-build.sh          # Manual Docker build script
    README.md                # This file
  security-gates/
    sonarqube-quality-gate.yml  # Quality Gate configuration
    owasp-threshold.yml         # Threshold for OWASP DC
    trivy-policy.yml            # Policy for Trivy scan
```

## How to Run the Pipeline

### Auto Trigger (Webhook)
1. Configure GitHub Webhook → Jenkins URL
2. Webhook fires on push to App Repo

### Manual Trigger
1. Go to Jenkins → Retail Store Pipeline → Build with Parameters
2. Select branch, image tag (optional)
3. Build

## Checking Security Gates

### SonarQube
```
http://<sonarqube-server>:9000/dashboard?id=uit-devsecops-retail-store
```
Check Quality Gate status (PASS/FAIL)

### OWASP Dependency Check
Report: `dependency-check-report/dependency-check-report.html`
Check for dependencies with CVSS >= 7.0

### Trivy
Report: `trivy-report-<service>.json` (archived in Jenkins artifacts)
Check for CRITICAL vulnerabilities

## Troubleshooting

### Error: SonarQube Quality Gate FAILED
→ Open SonarQube dashboard, review issues, fix code, push again

### Error: OWASP DC found HIGH CVE
→ Check report, if false positive → add to `owasp-suppressions.xml`

### Error: Trivy found CRITICAL CVE
→ Check base image, update base image version

### Error: ECR login failed
→ Verify `aws-credentials` is configured correctly in Jenkins
→ Ensure the IAM user has `AmazonEC2ContainerRegistryPowerUser`
→ Test: `aws sts get-caller-identity --profile <profile>`

### Error: GitOps repo push failed
→ Check that SSH key has been added to GitHub repo
→ Check write permissions on the GitOps repo
