resource "aws_lb" "main" {

  name = "${var.project_name}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {

    Name = "${var.project_name}-alb"

    Environment = var.environment

    Project = var.project_name
  }
}


resource "aws_lb_target_group" "app" {

  name = "${var.project_name}-tg"

  port = 5000

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = aws_vpc.main.id

  health_check {

    enabled = true

    path = "/health"

    matcher = "200"

    protocol = "HTTP"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2
  }

  tags = {

    Name = "${var.project_name}-tg"

    Environment = var.environment

    Project = var.project_name
  }
}


resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.main.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app.arn
  }
}