#!/bin/bash
# ============================================================
# Docker build script for all 5 microservices
# Usage:
#   ./docker-build.sh <service> <image-tag>
#   ./docker-build.sh all abc1234
# ============================================================

set -e

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
ECR_BASE_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ENV_NAME="${ENVIRONMENT_NAME:-uit-devsecops-dev}"
IMAGE_TAG="${2:-latest}"
SERVICE="$1"

# ECR Login
aws ecr get-login-password --region "${AWS_REGION}" \
    | docker login --username AWS --password-stdin "${ECR_BASE_URL}"

build_service() {
    local svc="$1"
    local dockerfile="src/${svc}/Dockerfile"
    local image="${ECR_BASE_URL}/${ENV_NAME}-${svc}"

    if [ ! -f "${dockerfile}" ]; then
        echo "Error: Dockerfile not found at ${dockerfile}"
        exit 1
    fi

    echo "Building ${svc}..."
    echo "  Dockerfile: ${dockerfile}"
    echo "  Image: ${image}:${IMAGE_TAG}"

    docker build \
        -t "${image}:${IMAGE_TAG}" \
        -t "${image}:latest" \
        -f "${dockerfile}" \
        "src/${svc}/"

    echo "  Built successfully: ${image}:${IMAGE_TAG}"
}

push_service() {
    local svc="$1"
    local image="${ECR_BASE_URL}/${ENV_NAME}-${svc}"

    echo "Pushing ${svc}..."
    docker push "${image}:${IMAGE_TAG}"
    docker push "${image}:latest"
    echo "  Pushed: ${image}:${IMAGE_TAG}"
}

scan_service() {
    local svc="$1"
    local image="${ECR_BASE_URL}/${ENV_NAME}-${svc}:${IMAGE_TAG}"

    echo "Scanning ${svc} with Trivy..."
    trivy image \
        --severity CRITICAL,HIGH \
        --format table \
        --exit-code 1 \
        "${image}"

    echo "  Scan passed: ${svc}"
}

# Main
if [ "$SERVICE" = "all" ]; then
    SERVICES="ui cart orders catalog checkout"
else
    SERVICES="$SERVICE"
fi

for svc in $SERVICES; do
    build_service "$svc"
    scan_service "$svc"
    push_service "$svc"
done

echo ""
echo "========================================"
echo "All services built, scanned, and pushed!"
echo "Image tag: ${IMAGE_TAG}"
echo "========================================"
