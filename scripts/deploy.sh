#!/bin/bash

set -e


IMAGE_TAG="${GITHUB_SHA:-latest}"

echo "Using image tag: $IMAGE_TAG"


echo "========================================"
echo "Building Docker image..."
echo "========================================"

docker build \
  -t "$ECR_REPOSITORY:latest" \
  -t "$ECR_REPOSITORY:$IMAGE_TAG" \
  ./app

echo "========================================"
echo "Logging in to Amazon ECR..."
echo "========================================"

aws ecr get-login-password --region "$AWS_REGION" | \
docker login \
  --username AWS \
  --password-stdin \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "========================================"
echo "Tagging Docker images..."
echo "========================================"

docker tag \
  "$ECR_REPOSITORY:latest" \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest"

docker tag \
  "$ECR_REPOSITORY:$IMAGE_TAG" \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"

echo "========================================"
echo "Pushing Docker images..."
echo "========================================"

docker push \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest"

docker push \
  "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG"

echo "========================================"
echo "Triggering ECS deployment..."
echo "========================================"

aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --force-new-deployment \
  --region "$AWS_REGION"


echo "Waiting for ECS service to become stable..."

aws ecs wait services-stable \
  --cluster "$ECS_CLUSTER" \
  --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

echo "========================================"
echo "Deployment triggered successfully."
echo "========================================"