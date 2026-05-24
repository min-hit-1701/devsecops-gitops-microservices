# Jenkins Shared Library — DevSecOps Pipeline

Reusable pipeline functions for build, security scanning, Docker operations, and GitOps updates.

Ref: https://www.jenkins.io/doc/book/pipeline/shared-libraries/

## Setup in Jenkins

1. Go to **Manage Jenkins > Configure System > Global Pipeline Libraries**
2. Add a new library:
   - **Name:** `devsecops-shared-library`
   - **Default version:** `main`
   - **Retrieval method:** Modern SCM
   - **Source Code Management:** Git
   - **Repository URL:** `https://github.com/min-hit-1701/devsecops-gitops-microservices.git`
   - **Library path:** `05-ci/jenkins-shared-library`
3. Check **Load implicitly** or use `@Library('devsecops-shared-library') _` in your Jenkinsfile

## Available Functions

| Function | Stage | Description |
|---|---|---|
| `awsSetup()` | AWS Setup | Resolve account ID via sts:GetCallerIdentity, set ECR_BASE_URL |
| `buildService(name)` | Build | Build a single service (Java Maven / Go / Node.js) |
| `sonarQubeAnalysis()` | SonarQube SAST | Run SAST + wait for Quality Gate (Security Gate 1) |
| `owaspDependencyCheck()` | OWASP DC | Scan dependencies for CVEs >= 7.0 (Security Gate 2) |
| `dockerBuildAndPush()` | Docker | Build images, Trivy scan (Security Gate 3), push to ECR |
| `updateGitOpsRepo()` | GitOps | Clone GitOps repo, update image tags, commit & push |

## File Structure

```
05-ci/jenkins-shared-library/
  vars/
    awsSetup.groovy              # Dynamic AWS account ID resolution
    buildService.groovy          # Build per service type
    sonarQubeAnalysis.groovy     # SonarQube SAST + Quality Gate
    owaspDependencyCheck.groovy  # OWASP Dependency Check
    dockerBuildAndPush.groovy    # Docker build + Trivy + ECR push
    updateGitOpsRepo.groovy      # GitOps repo tag update
  src/                           # (reserved for complex Java/Groovy classes)
  README.md                      # This file
```

## Jenkinsfile Usage

After configuring the shared library, the Jenkinsfile becomes clean and declarative:

```groovy
@Library('devsecops-shared-library') _

pipeline {
    stages {
        stage('Checkout')     { steps { ... } }
        stage('AWS Setup')    { steps { awsSetup() } }
        stage('Build')        { steps { /* parallel: buildService() */ } }
        stage('SonarQube')    { steps { sonarQubeAnalysis() } }
        stage('OWASP DC')     { steps { owaspDependencyCheck() } }
        stage('Docker')       { steps { dockerBuildAndPush() } }
        stage('GitOps')       { steps { updateGitOpsRepo() } }
    }
}
```

## Required Jenkins Plugins

- CloudBees AWS Credentials
- Amazon ECR
- Docker Pipeline
- SonarQube Scanner
- SSH Agent
- Pipeline Utility Steps
