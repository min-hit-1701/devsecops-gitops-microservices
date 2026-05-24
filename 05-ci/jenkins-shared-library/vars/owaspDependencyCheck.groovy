#!/usr/bin/env groovy

/**
 * Run OWASP Dependency Check (SCA) against all project dependencies.
 * Blocks the pipeline if any dependency has CVSS >= 7.0 (HIGH or CRITICAL).
 *
 * Usage:
 *   owaspDependencyCheck()
 *
 * Required:
 *   - OWASP Dependency Check installed at /opt/dependency-check/
 *   - Environment: OWASP_NVD_API_KEY
 */
def call() {
    echo "=== SECURITY GATE 2: OWASP Dependency Check ==="

    sh '''
        /opt/dependency-check/bin/dependency-check.sh \
            --scan src/ \
            --format HTML \
            --format JSON \
            --out dependency-check-report \
            --failOnCVSS 7 \
            --nvdApiKey ${OWASP_NVD_API_KEY} \
            || true

        HIGH_COUNT=$(python3 -c "
import json
with open(\'dependency-check-report/dependency-check-report.json\') as f:
    data = json.load(f)
count = 0
for dep in data.get(\'dependencies\', []):
    for vuln in dep.get(\'vulnerabilities\', []):
        if vuln.get(\'cvssv3\', {}).get(\'baseScore\', 0) >= 7.0:
            count += 1
print(count)
        ")

        echo "OWASP DC: ${HIGH_COUNT} dependencies with CVSS >= 7.0"

        if [ "${HIGH_COUNT}" -gt 0 ]; then
            echo "OWASP Dependency Check found HIGH/CRITICAL vulnerabilities"
            echo "Pipeline blocked by Security Gate 2"
            exit 1
        fi
    '''
}
