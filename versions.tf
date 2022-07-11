# Terraform Block
terraform {
  required_version = ">= 0.14" # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3"
    }    
    random = {
      source = "hashicorp/random"
      version = "~> 3"
    }            
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "dr-dev-state-file-bucket-20220708060736188100000001"
    key    = "dev/lambda-EMR/terraform.tfstate"
    region = "us-west-2" 

    # Enable during Step-09     
    # For State Locking
    dynamodb_table = "lambda-EMR"    
  }    
}

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

provider "aws" {
  alias  = "region2"
  region  = var.aws_region2
}

