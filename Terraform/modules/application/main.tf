# ============================================================
# Target Group
# ============================================================

resource "aws_lb_target_group" "this" {
  name = "${var.environment}-${var.service_name}-tg"

  port = var.target_group_port

  protocol = "HTTP"

  vpc_id = data.aws_subnet.selected.vpc_id

  health_check {
    path = var.health_check_path

    protocol = "HTTP"

    matcher = "200-399"

    healthy_threshold = 2

    unhealthy_threshold = 3

    interval = 30

    timeout = 5
  }

  tags = {
    Name    = "${var.environment}-${var.service_name}-tg"
    Service = var.service_name
  }
}


# Get the VPC ID from the first application subnet.
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}


# ============================================================
# ALB Listener Rule
# ============================================================

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn

  priority = var.listener_rule_priority

  action {
    type = "forward"

    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = [
        var.listener_rule_path
      ]
    }
  }
}


# ============================================================
# Launch Template
# ============================================================

resource "aws_launch_template" "this" {
  name_prefix = "${var.environment}-${var.service_name}-"

  image_id = var.ami_id

  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.environment}-${var.service_name}"
      Service = var.service_name
    }
  }
}


# ============================================================
# Auto Scaling Group
# ============================================================

resource "aws_autoscaling_group" "this" {
  name = "${var.environment}-${var.service_name}-asg"

  min_size = 1

  desired_capacity = 1

  max_size = 2

  vpc_zone_identifier = var.subnet_ids

  health_check_type = "ELB"

  health_check_grace_period = 120

  target_group_arns = [
    aws_lb_target_group.this.arn
  ]

  launch_template {
    id = aws_launch_template.this.id

    version = "$Latest"
  }

  tag {
    key = "Name"

    value = "${var.environment}-${var.service_name}"

    propagate_at_launch = true
  }

  tag {
    key = "Service"

    value = var.service_name

    propagate_at_launch = true
  }
}
