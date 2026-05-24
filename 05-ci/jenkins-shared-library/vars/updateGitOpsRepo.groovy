#!/usr/bin/env groovy

/**
 * Clone the GitOps repo, update image tags in all Kustomize overlays,
 * commit and push. Argo CD will auto-sync upon detecting the new commit.
 *
 * Usage:
 *   updateGitOpsRepo()
 *
 * Required:
 *   - SSH key added to Jenkins as 'gitops-deploy-key' credential
 *   - Environment: GITOPS_REPO_URL, GITOPS_REPO_PATH, SERVICES
 *   - Image vars: ECR_BASE_URL, ENVIRONMENT_NAME, IMAGE_TAG
 */
def call() {
    echo "Updating GitOps repo with new image tags..."

    sshagent(['gitops-deploy-key']) {
        sh '''
            git clone ${GITOPS_REPO_URL} ${GITOPS_REPO_PATH}
            cd ${GITOPS_REPO_PATH}

            SERVICES="ui cart orders catalog checkout"
            for svc in $SERVICES; do
                IMAGE="${ECR_BASE_URL}/${ENVIRONMENT_NAME}-${svc}"
                echo "Updating ${svc} to tag ${IMAGE_TAG}..."

                find apps/ -name kustomization.yaml | while read f; do
                    if grep -q "name: ${svc}" "$f" 2>/dev/null; then
                        python3 -c "
import yaml, sys
with open(\'${f}\', \'r\') as file:
    data = list(yaml.safe_load_all(file))
for doc in data:
    if doc and \'images\' in doc:
        for img in doc[\'images\']:
            if img.get(\'name\') == \'${svc}\':
                img[\'newTag\'] = \'${IMAGE_TAG}\'
with open(\'${f}\', \'w\') as file:
    yaml.dump_all(data, file)
                        "
                    fi
                done
            done

            git config user.email "ci-bot@devsecops.local"
            git config user.name "CI Bot"

            if ! git diff --quiet; then
                git add .
                git commit -m "ci: update image tags to ${IMAGE_TAG} [skip ci]"
                git push origin HEAD
                echo "GitOps repo updated successfully"
            else
                echo "No changes to commit in GitOps repo"
            fi
        '''
    }
}
