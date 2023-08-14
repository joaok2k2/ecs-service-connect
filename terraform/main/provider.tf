terraform {
  backend "s3" {
    bucket = "terraform-course-tfstate-431591413306"
    key    = "ecs-service-connect/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}
