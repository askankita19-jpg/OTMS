variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "enable_https" {
  type = bool
}

variable "certificate_arn" {
  type = string

  validation {
    condition = (
      !var.enable_https ||
      var.certificate_arn != ""
    )

    error_message = "certificate_arn is required when HTTPS is enabled."
  }
}
