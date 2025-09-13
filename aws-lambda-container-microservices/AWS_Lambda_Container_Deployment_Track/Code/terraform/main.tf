terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source = "./modules/ecr"
}

module "lambda" {
  source = "./modules/lambda"
  ecr_repo_url = module.ecr.repository_url
}

module "apigateway" {
  source = "./modules/apigateway"
  lambda_function_name = module.lambda.function_name
}
