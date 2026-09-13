resource "aws_instance" "this" {
  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  associate_public_ip_address = false

  iam_instance_profile = var.iam_instance_profile

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 20

    volume_type = "gp3"

    encrypted = true

    delete_on_termination = true
  }

  tags = {
    Name      = "${var.environment}-otms-${var.database_name}"
    Component = "database"
    Database  = var.database_name
  }
}
