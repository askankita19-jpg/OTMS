locals {
  create_applications = var.deployment_phase == "application"
}

resource "aws_iam_role" "ssm" {
  name = "${var.environment}-otms-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.environment}-otms-ssm-profile"
  role = aws_iam_role.ssm.name
}

module "network" {
  source = "./modules/network"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  enable_https        = var.enable_https
  certificate_arn     = var.certificate_arn
}

data "aws_ami" "ubuntu" {
  count = var.database_ami_id == "" ? 1 : 0

  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  database_ami = var.database_ami_id != "" ? var.database_ami_id : data.aws_ami.ubuntu[0].id

  databases = {
    postgresql = {}
    redis      = {}
    scylladb   = {}
  }
}

module "database" {
  for_each = local.databases

  source = "./modules/database"

  environment          = var.environment
  database_name        = each.key
  ami_id               = local.database_ami
  instance_type        = var.database_instance_type
  subnet_id            = module.network.private_database_subnet_id
  security_group_id    = module.network.database_security_group_ids[each.key]
  iam_instance_profile = aws_iam_instance_profile.ssm.name
}

locals {
  applications = {
    frontend = {
      service_name = "frontend"
      port         = 3000
      health_path  = "/"
      path_pattern = "/*"
      priority     = 100
    }

    employee = {
      service_name = "employee-api"
      port         = 8080
      health_path  = "/api/v1/employee/health"
      path_pattern = "/api/v1/employee/*"
      priority     = 10
    }

    attendance = {
      service_name = "attendance-api"
      port         = 8081
      health_path  = "/api/v1/attendance/health"
      path_pattern = "/api/v1/attendance/*"
      priority     = 20
    }

    salary = {
      service_name = "salary-api"
      port         = 8082
      health_path  = "/actuator/health"
      path_pattern = "/api/v1/salary/*"
      priority     = 30
    }

    notification = {
      service_name = "notification-api"
      port         = 8085
      health_path  = "/api/v1/notification/health/detail"
      path_pattern = "/api/v1/notification/*"
      priority     = 40
    }
  }
}

module "application" {
  for_each = local.create_applications ? local.applications : {}

  source = "./modules/application"

  environment             = var.environment
  service_name            = each.value.service_name
  ami_id                  = var.application_amis[each.key]
  instance_type           = var.application_instance_type
  subnet_ids              = module.network.private_app_subnet_ids
  security_group_id       = module.network.application_security_group_id
  target_group_port       = each.value.port
  health_check_path       = each.value.health_path
  listener_arn            = module.network.application_listener_arn
  listener_rule_priority  = each.value.priority
  listener_rule_path      = each.value.path_pattern
  iam_instance_profile    = aws_iam_instance_profile.ssm.name
}
