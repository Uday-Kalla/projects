terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# A provider "aws" {} block represents one AWS region/session.
# If you try to set both region and alias for multiple regions in a single block, Terraform won’t know which region to target.

# Default provider (no alias) → us-east-1
provider "aws" {
  region = "us-east-1"
}

# Aliased provider → ap-southeast-2
provider "aws" {
  alias  = "ap"
  region = "ap-southeast-2"
}

# ---------------- Locals ----------------
locals {
  project_name = "healthcare"
  vpc_cidr     = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway          = true
  s3_bucket_name              = "healthcare-deploy01"
  ecr_repository_name         = "healthcare-ecr"
  cluster_name                = "healthcare-cluster"
  node_group_desired_capacity = 2

  # Flags to control optional resources
  create_ecr = false
  create_eks = false
}

# ---------------- VPC ----------------
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(local.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.project_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${local.project_name}-private-${count.index + 1}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_eip" "nat" {
  count      = local.enable_nat_gateway ? 1 : 0
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  count         = local.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${local.project_name}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = local.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[0].id
  }
  tags = {
    Name = "${local.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.enable_nat_gateway ? length(aws_subnet.private[*].id) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# ---------------- S3 Bucket ----------------
resource "aws_s3_bucket" "Bucket" {
  # Uses Sydney provider (ap-southeast-2)
   provider = aws.ap
  bucket = local.s3_bucket_name
  tags = {
    Name = "${local.project_name}-bucket"
  }
}

# ---------------- ECR (Optional) ----------------
resource "aws_ecr_repository" "ecr" {
  count = local.create_ecr ? 1 : 0
  name  = local.ecr_repository_name
  tags = {
    Name = "${local.project_name}-ecr"
  }
}

# ---------------- EKS (Optional) ----------------
resource "aws_iam_role" "eks_cluster_role" {
  count = local.create_eks ? 1 : 0
  name  = "${local.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_attach" {
  count      = local.create_eks ? 1 : 0
  role       = aws_iam_role.eks_cluster_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks" {
  count    = local.create_eks ? 1 : 0
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role[0].arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_attach]
}

# ---------------- API Gateway ----------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.project_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# ---------------- Outputs ----------------
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "s3_bucket" {
  value = aws_s3_bucket.Bucket.id
}

output "ecr_repository_url" {
  value = local.create_ecr ? aws_ecr_repository.ecr[0].repository_url : null
}

output "eks_cluster_endpoint" {
  value = local.create_eks ? aws_eks_cluster.eks[0].endpoint : null
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
