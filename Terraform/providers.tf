provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "OTMS"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
