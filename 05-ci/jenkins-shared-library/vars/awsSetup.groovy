#!/usr/bin/env groovy

/**
 * Resolve AWS Account ID dynamically and set ECR_BASE_URL.
 * Uses withAWS() from the CloudBees AWS Credentials plugin.
 *
 * Usage:
 *   awsSetup()
 *
 * Required:
 *   - AWS_CREDENTIALS_ID, AWS_REGION
 *
 * Output (environment variables):
 *   - AWS_ACCOUNT_ID
 *   - ECR_BASE_URL
 */
def call() {
    withAWS(region: "${env.AWS_REGION}", credentials: "${env.AWS_CREDENTIALS_ID}") {
        script {
            def accountId = sh(
                script: 'aws sts get-caller-identity --query Account --output text',
                returnStdout: true
            ).trim()

            env.AWS_ACCOUNT_ID = accountId
            env.ECR_BASE_URL   = "${accountId}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"

            echo "AWS Account: ${accountId}"
            echo "ECR Registry: ${env.ECR_BASE_URL}"
        }
    }
}
