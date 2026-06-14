# Kaniko Build Job — builds Docker images and pushes to ECR without Docker daemon
# Each service runs as a separate Kubernetes Job
# Requires IRSA: jenkins service account must have ECR push permissions

# Variables (replace per service)
# SERVICE=ui|carts|orders|catalog|checkout
# IMAGE_TAG=git-sha

export AWS_REGION="ap-southeast-1"
export AWS_ACCOUNT_ID="758346258990"
export ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export ENV_NAME="uit-devsecops-dev"

# Service: catalog (Go — fastest build)
SERVICE="catalog"
IMAGE_TAG="kaniko-test-$(date +%s)"

echo "Building ${SERVICE} with Kaniko..."
echo "Image: ${ECR_BASE}/${ENV_NAME}-${SERVICE}:${IMAGE_TAG}"

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: kaniko-build-${SERVICE}
  namespace: jenkins
  labels:
    app: kaniko
    service: ${SERVICE}
spec:
  ttlSecondsAfterFinished: 300
  backoffLimit: 1
  template:
    metadata:
      labels:
        service: ${SERVICE}
    spec:
      restartPolicy: Never
      serviceAccountName: jenkins
      containers:
        - name: kaniko
          image: gcr.io/kaniko-project/executor:latest
          args:
            - "--context=git://github.com/min-hit-1701/retail-store-app.git#refs/heads/main"
            - "--context-sub-path=src/${SERVICE}"
            - "--dockerfile=src/${SERVICE}/Dockerfile"
            - "--destination=${ECR_BASE}/${ENV_NAME}-${SERVICE}:${IMAGE_TAG}"
            - "--destination=${ECR_BASE}/${ENV_NAME}-${SERVICE}:latest"
            - "--cache=true"
            - "--verbosity=info"
          env:
            - name: AWS_REGION
              value: "${AWS_REGION}"
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 500m
              memory: 1Gi
EOF

echo "Kaniko job created for ${SERVICE}"
echo "Check: kubectl logs -n jenkins job/kaniko-build-${SERVICE} -f"
