variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "listener_rule_priority" {
  type = number
}

variable "listener_rule_path" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}
