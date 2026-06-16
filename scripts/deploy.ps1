param (
    [string]$Region,
    [string]$Repository,
    [string]$Cluster,
    [string]$Service,
    [string]$AccountId
)

Write-Host "Building Docker image..."
docker build -t $Repository ./app

Write-Host "Logging in to Amazon ECR..."
$password = aws ecr get-login-password --region $Region
$password | docker login `
    --username AWS `
    --password-stdin `
    "$AccountId.dkr.ecr.$Region.amazonaws.com"

Write-Host "Tagging Docker image..."
docker tag `
    "${Repository}:latest" `
    "$AccountId.dkr.ecr.$Region.amazonaws.com/${Repository}:latest"

Write-Host "Pushing Docker image..."
docker push `
    "$AccountId.dkr.ecr.$Region.amazonaws.com/${Repository}:latest"

Write-Host "Triggering ECS deployment..."
aws ecs update-service `
    --cluster $Cluster `
    --service $Service `
    --force-new-deployment `
    --region $Region

Write-Host "Deployment triggered successfully."