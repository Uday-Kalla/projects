provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "lambda" {
  source            = "./modules/lambda"
  project_name      = var.project_name
  lambda_image_uri  = var.lambda_image_uri
  subnet_ids        = [module.vpc.private_subnet_id]
  security_group_id = module.security.sg_id
  role_arn          = module.iam.lambda_role_arn
}

module "apigateway" {
  source            = "./modules/apigateway"
  project_name      = var.project_name
  lambda_arn        = module.lambda.lambda_arn
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  project_name    = var.project_name
  lambda_name     = module.lambda.lambda_name
  api_id          = module.apigateway.api_id
  execution_arn   = module.apigateway.execution_arn
}
