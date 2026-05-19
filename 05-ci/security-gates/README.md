# Security Gates

Fail/pass configuration for the 3 security gates in the CI pipeline:

- `sonarqube-quality-gate.yml` — Quality Gate conditions (security, reliability, coverage)
- `owasp-threshold.yml` — CVSS threshold (>=7.0 block), suppression rules
- `trivy-policy.yml` — Trivy scan severity, ignore rules
