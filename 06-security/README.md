# IaC Security Scanning — Checkov & Terrascan

Two tools for scanning Terraform code for security misconfigurations and policy violations.

Refs:
- https://www.checkov.io/
- https://runterrascan.io/

## Installation

### Checkov
```bash
pip install checkov
```

### Terrascan
```bash
curl -L https://github.com/tenable/terrascan/releases/download/v1.18.11/terrascan_1.18.11_Linux_x86_64.tar.gz | tar xz
sudo mv terrascan /usr/local/bin/
```

## Usage

```bash
# Terrascan
terrascan scan -d 03-infra/terraform/modules/ -i terraform -o human

# Checkov
checkov -d 03-infra/terraform/modules/ --compact

# Save as JSON
terrascan scan -d 03-infra/terraform/modules/ -i terraform -o json > terrascan-report.json
```

## Latest Scan Results (2026-05-24)

### Terrascan — modules/

| Severity | Count |
|---|---|
| LOW | 1 (VPC module cache, not our code) |
| MEDIUM | 0 |
| HIGH | 0 |
| Policies validated | 198 |

### Issues Fixed

1. **ECR encryption** — Added `encryption_configuration { encryption_type = "AES256" }` to ECR module
2. **ECR repository policy** — Added `aws_ecr_repository_policy` restricting access to current AWS account
3. **VPC Flow Logs** — Added flow logging with CloudWatch Logs destination to VPC module
