resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "sre-portfolio-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_subnet" "public_a" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-a"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_subnet" "public_b" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "${var.aws_region}b"

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-b"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_subnet" "private_a" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.3.0/24"

  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-a"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_route_table_association" "private_a" {

  subnet_id = aws_subnet.private_a.id

  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "private_b" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.4.0/24"

  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-b"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_route_table_association" "private_b" {

  subnet_id = aws_subnet.private_b.id

  route_table_id = aws_route_table.private.id
}


resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public_a.id

  tags = {
    Name        = "${var.project_name}-nat-gateway"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}


resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_route" "private_nat_access" {

  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.main.id
}







resource "aws_route" "public_internet_access" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_a" {

  subnet_id = aws_subnet.public_a.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {

  subnet_id = aws_subnet.public_b.id

  route_table_id = aws_route_table.public.id
}



resource "aws_security_group" "alb" {

  name        = "${var.project_name}-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "${var.project_name}-alb-sg"

    Environment = var.environment

    Project = var.project_name
  }
}



resource "aws_security_group" "ecs" {

  name = "${var.project_name}-ecs-sg"

  description = "Security Group for ECS Tasks"

  vpc_id = aws_vpc.main.id

  ingress {

    description = "Application Traffic from ALB"

    from_port = 5000

    to_port = 5000

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {

    Name = "${var.project_name}-ecs-sg"

    Environment = var.environment

    Project = var.project_name
  }
}



resource "aws_ecr_repository" "app" {

  name = "${var.project_name}-app"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {

    scan_on_push = true
  }

  tags = {

    Name = "${var.project_name}-app"

    Environment = var.environment

    Project = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "ecs" {

  name = "/ecs/${var.project_name}"

  retention_in_days = 14

  tags = {

    Environment = var.environment

    Project = var.project_name
  }
}



resource "aws_ecs_cluster" "main" {

  name = "${var.project_name}-cluster"

  tags = {

    Name = "${var.project_name}-cluster"

    Environment = var.environment

    Project = var.project_name
  }
}