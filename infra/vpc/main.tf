terraform {
  backend "s3" {
    bucket         = "terraform-state-mja123"
    key            = "vpc-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-state"
    encrypt        = true
    profile        = "personal"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0"
    }
  }
  required_version = "1.7.4"
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}


