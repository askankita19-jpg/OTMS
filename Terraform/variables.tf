variable "aws_region" {
  description = "AWS region where OTMS will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the OTMS VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones for OTMS."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Provide exactly two availability zones."
  }
}

variable "application_amis" {
  description = "AMI IDs created by Packer for the OTMS applications."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name in [
        "frontend",
        "employee",
        "attendance",
        "salary",
        "notification"
      ] : contains(keys(var.application_amis), name)
    ]) || var.deployment_phase == "foundation"

    error_message = "Application phase requires AMIs for frontend, employee, attendance, salary and notification."
  }
}

variable "application_instance_type" {
  description = "EC2 instance type for application servers."
  type        = string
  default     = "t3.micro"
}

variable "database_instance_type" {
  description = "EC2 instance type for database servers."
  type        = string
  default     = "t3.micro"
}

variable "deployment_phase" {
  description = "foundation or application."
  type        = string
  default     = "foundation"

  validation {
    condition = contains(
      ["foundation", "application"],
      var.deployment_phase
    )

    error_message = "deployment_phase must be foundation or application."
  }
}

variable "enable_https" {
  description = "Enable HTTPS using an ACM certificate."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN."
  type        = string
  default     = ""
}

variable "database_ami_id" {
  description = "Optional AMI ID for database servers. Leave empty to use latest Ubuntu 24.04."
  type        = string
  default     = ""
}
