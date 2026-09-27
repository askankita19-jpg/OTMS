packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "application" {
  type = string
}

variable "version" {
  type = string
}

variable "artifact_path" {
  type = string
}

variable "source_ami" {
  type    = string
  default = ""
}

locals {
  ami_name = "otms-${var.application}-${var.version}"
}

source "amazon-ebs" "otms" {
  region        = var.aws_region
  instance_type = "t3.micro"

  source_ami = var.source_ami

  ssh_username = "ubuntu"

  ami_name = local.ami_name

  tags = {
    Name        = local.ami_name
    Application = var.application
    Version     = var.version
    Project     = "OTMS"
  }
}

build {
  name    = "otms-${var.application}"
  sources = ["source.amazon-ebs.otms"]

  provisioner "file" {
    source      = var.artifact_path
    destination = "/tmp/application-artifact"
  }

  provisioner "shell" {
    script = "${path.root}/${var.application}/install.sh"
  }
}
