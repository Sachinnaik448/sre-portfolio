resource "aws_ecs_service" "app" {

  name = "${var.project_name}-service"

  cluster = aws_ecs_cluster.main.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 2

  launch_type = "FARGATE"

  deployment_minimum_healthy_percent = 50

  deployment_maximum_percent = 200

  network_configuration {

    subnets = [

      aws_subnet.private_a.id,

      aws_subnet.private_b.id

    ]

    security_groups = [

      aws_security_group.ecs.id

    ]

    assign_public_ip = false
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.app.arn

    container_name = "app"

    container_port = 5000
  }

  depends_on = [

    aws_lb_listener.http

  ]

  tags = {

    Name = "${var.project_name}-service"

    Environment = var.environment

    Project = var.project_name
  }
}