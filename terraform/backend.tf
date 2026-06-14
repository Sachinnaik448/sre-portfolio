terraform {
  backend "s3" {
    bucket         = "sre-portfolio-tfstate-821135790190"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}