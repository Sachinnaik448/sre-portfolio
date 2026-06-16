resource "aws_ecs_task_definition" "app" {

  family = "${var.project_name}-task"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = "256"

  memory = "512"

  runtime_platform {

    operating_system_family = "LINUX"

    cpu_architecture = "X86_64"
  }

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([

    {

      name = "app"

      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [

        {

          containerPort = 5000

          hostPort = 5000

          protocol = "tcp"
        }
      ]

      environment = [

        {

          name = "AWS_REGION"

          value = var.aws_region
        },

        {

          name = "ENVIRONMENT"

          value = var.environment
        },

        {

          name = "APP_VERSION"

          value = "1.0.0"
        }
      ]

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.ecs.name

          awslogs-region = var.aws_region

          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}