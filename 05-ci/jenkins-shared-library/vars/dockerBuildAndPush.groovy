#!/usr/bin/env groovy

/**
 * Build Docker images, scan with Trivy, and push to ECR.
 * All 5 services run in parallel.
 *
 * AWS authentication: uses withAWS() and docker.withRegistry("ecr:...")
 * No account ID hardcoded — resolved via sts:GetCallerIdentity at runtime.
 *
 * Usage:
 *   dockerBuildAndPush()
 *
 * Required Jenkins Plugins:
 *   - CloudBees AWS Credentials Plugin
 *   - Amazon ECR Plugin
 *   - Docker Pipeline Plugin
 *
 * Required Environment:
 *   - AWS_REGION, AWS_CREDENTIALS_ID, ENVIRONMENT_NAME
 *   - SERVICES (comma-separated), IMAGE_TAG, TRIVY_SEVERITY
 *   - ECR_BASE_URL (set by awsSetup stage)
 */
def call() {
    withAWS(region: "${env.AWS_REGION}", credentials: "${env.AWS_CREDENTIALS_ID}") {
        docker.withRegistry(
            "https://${env.ECR_BASE_URL}",
            "ecr:${env.AWS_REGION}:${env.AWS_CREDENTIALS_ID}"
        ) {
            def buildSteps = [:]
            def services = env.SERVICES.split(',')

            services.each { service ->
                def svc = service.trim()
                def imageName      = "${env.ENVIRONMENT_NAME}-${svc}"
                def fullName       = "${env.ECR_BASE_URL}/${imageName}"
                def dockerfilePath = "src/${svc}/Dockerfile"

                buildSteps[svc] = {
                    if (!fileExists(dockerfilePath)) {
                        error "Dockerfile not found: ${dockerfilePath}"
                    }

                    // Build
                    docker.build(
                        "${imageName}:${env.IMAGE_TAG}",
                        "-f ${dockerfilePath} src/${svc}/"
                    )
                    sh "docker tag ${imageName}:${env.IMAGE_TAG} ${fullName}:${env.IMAGE_TAG}"
                    sh "docker tag ${imageName}:${env.IMAGE_TAG} ${fullName}:latest"

                    // SECURITY GATE 3: Trivy scan
                    sh """
                        trivy image --severity ${env.TRIVY_SEVERITY} \
                            --format json \
                            --output trivy-report-${svc}.json \
                            --exit-code 0 \
                            ${fullName}:${env.IMAGE_TAG}

                        CRIT_COUNT=\$(python3 -c "
import json
with open(\'trivy-report-${svc}.json\') as f:
    data = json.load(f)
count = sum(1 for r in data.get(\'Results\', []) for v in r.get(\'Vulnerabilities\', []) if v.get(\'Severity\') == \'CRITICAL\')
print(count)
                        ")
                        echo "${svc}: \${CRIT_COUNT} CRITICAL vulnerabilities"

                        if [ "\${CRIT_COUNT}" -gt 0 ]; then
                            echo "Trivy found CRITICAL vulnerabilities in ${svc}"
                            exit 1
                        fi
                    """

                    // Push
                    docker.image(fullName).push(env.IMAGE_TAG)
                    docker.image(fullName).push('latest')
                    echo "Built + Scanned + Pushed: ${fullName}:${env.IMAGE_TAG}"
                }
            }

            parallel buildSteps
        }
    }
}
