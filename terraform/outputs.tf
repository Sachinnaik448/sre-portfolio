output "aws_region" {
  description = "AWS region configured for deployment"

  value = var.aws_region
}

output "project_name" {
  description = "Project name"

  value = var.project_name
}

output "environment" {
  description = "Deployment environment"

  value = var.environment
}




output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "Amazon ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service Name"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_family" {
  description = "ECS Task Definition Family"
  value       = aws_ecs_task_definition.app.family
}