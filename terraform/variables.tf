variable "aws_region" {
  description = "AWS region where resources will be created"

  type = string

  default = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"

  type = string

  default = "sre-portfolio"
}

variable "environment" {
  description = "Deployment environment"

  type = string

  default = "development"

  validation {
    condition = contains(
      [
        "development",
        "staging",
        "production"
      ],
      var.environment
    )

    error_message = "Environment must be development, staging or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"

  type = string

  default = "10.0.0.0/16"
}