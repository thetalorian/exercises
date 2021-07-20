provider "aws" {
    region = var.aws_region
}

terraform {
    backend "s3" {
        bucket         = "ik-buildreader-app-terraform-state"
        key            = "terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "ik_buildreader_app_locks"
        encrypt        = true
    }
}
