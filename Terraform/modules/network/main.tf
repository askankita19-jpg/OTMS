# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-otms-vpc"
  }
}


# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-otms-igw"
  }
}


# ============================================================
# Public Subnets
# ============================================================

resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.${count.index}.0/24"

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-otms-public-${count.index + 1}"
  }
}


# ============================================================
# Private Application Subnets
# ============================================================

resource "aws_subnet" "private_app" {
  count = 2

  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.${10 + count.index}.0/24"

  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-otms-app-${count.index + 1}"
  }
}


# ============================================================
# Private Database Subnet
# ============================================================

resource "aws_subnet" "private_database" {
  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.20.0/24"

  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.environment}-otms-database"
  }
}


# ============================================================
# NAT Gateway
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-otms-nat-eip"
  }
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.environment}-otms-nat"
  }
}


# ============================================================
# Public Route Table
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-otms-public-rt"
  }
}


resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id
}


resource "aws_route_table_association" "public" {
  count = 2

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}


# ============================================================
# Private Route Table
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-otms-private-rt"
  }
}


resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this.id
}


resource "aws_route_table_association" "private_app" {
  count = 2

  subnet_id = aws_subnet.private_app[count.index].id

  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private_database" {
  subnet_id = aws_subnet.private_database.id

  route_table_id = aws_route_table.private.id
}


# ============================================================
# ALB Security Group
# ============================================================

resource "aws_security_group" "alb" {
  name = "${var.environment}-otms-alb-sg"

  description = "Allow HTTP and HTTPS traffic to ALB"

  vpc_id = aws_vpc.this.id

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    description = "HTTPS"

    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.environment}-otms-alb-sg"
  }
}


# ============================================================
# Application Security Group
# ============================================================

resource "aws_security_group" "application" {
  name = "${var.environment}-otms-app-sg"

  description = "Allow application traffic only from ALB"

  vpc_id = aws_vpc.this.id

  ingress {
    description = "Frontend"

    from_port = 3000
    to_port   = 3000

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  ingress {
    description = "Employee API"

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  ingress {
    description = "Attendance API"

    from_port = 8081
    to_port   = 8081

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  ingress {
    description = "Salary API"

    from_port = 8082
    to_port   = 8082

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  ingress {
    description = "Notification API"

    from_port = 8085
    to_port   = 8085

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.environment}-otms-app-sg"
  }
}


# ============================================================
# PostgreSQL Security Group
# ============================================================

resource "aws_security_group" "postgresql" {
  name = "${var.environment}-otms-postgresql-sg"

  description = "Allow PostgreSQL from application servers"

  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 5432
    to_port   = 5432

    protocol = "tcp"

    security_groups = [
      aws_security_group.application.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


# ============================================================
# Redis Security Group
# ============================================================

resource "aws_security_group" "redis" {
  name = "${var.environment}-otms-redis-sg"

  description = "Allow Redis from application servers"

  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 6379
    to_port   = 6379

    protocol = "tcp"

    security_groups = [
      aws_security_group.application.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


# ============================================================
# ScyllaDB Security Group
# ============================================================

resource "aws_security_group" "scylladb" {
  name = "${var.environment}-otms-scylladb-sg"

  description = "Allow ScyllaDB from application servers"

  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 9042
    to_port   = 9042

    protocol = "tcp"

    security_groups = [
      aws_security_group.application.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


# ============================================================
# Application Load Balancer
# ============================================================

resource "aws_lb" "this" {
  name = "${var.environment}-otms-alb"

  load_balancer_type = "application"

  internal = false

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "${var.environment}-otms-alb"
  }
}


# ============================================================
# HTTP Listener
# ============================================================

resource "aws_lb_listener" "http" {
  count = var.enable_https ? 0 : 1

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"

      message_body = "OTMS is running"

      status_code = "200"
    }
  }
}


# ============================================================
# HTTP → HTTPS Redirect
# ============================================================

resource "aws_lb_listener" "http_redirect" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"

      protocol = "HTTPS"

      status_code = "HTTP_301"
    }
  }
}


# ============================================================
# HTTPS Listener
# ============================================================

resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn

  port = 443

  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"

      message_body = "OTMS is running"

      status_code = "200"
    }
  }
}
