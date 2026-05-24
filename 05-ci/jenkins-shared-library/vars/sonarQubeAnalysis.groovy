#!/usr/bin/env groovy

/**
 * Run SonarQube SAST analysis and wait for Quality Gate result.
 *
 * Usage:
 *   sonarQubeAnalysis()
 *
 * Required Jenkins configuration:
 *   - SonarQube server configured in Manage Jenkins > Configure System
 *   - SonarQube Scanner installed on the agent
 *   - Environment: SONAR_PROJECT_KEY, SONAR_HOST_URL, IMAGE_TAG
 */
def call() {
    echo "=== SECURITY GATE 1: SonarQube Static Analysis ==="

    withSonarQubeEnv('SonarQube') {
        sh """
            sonar-scanner \
                -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} \
                -Dsonar.sources=src/ \
                -Dsonar.java.binaries=src/*/target/ \
                -Dsonar.language=java,go,typescript,javascript \
                -Dsonar.projectName="Retail Store - DevSecOps" \
                -Dsonar.projectVersion=${env.IMAGE_TAG}
        """
    }

    timeout(time: 5, unit: 'MINUTES') {
        def qg = waitForQualityGate()
        if (qg.status != 'OK') {
            error "SonarQube Quality Gate FAILED: ${qg.status}"
        }
        echo "SonarQube Quality Gate PASSED"
    }
}
