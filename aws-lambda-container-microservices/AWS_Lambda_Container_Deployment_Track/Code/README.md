### Folder Structure
```css
appointment-service-infra/
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       ├── docker.yml
│       └── lambda-update.yml
├── modules/
│   ├── vpc/
│   │   └── main.tf
│   ├── iam/
│   │   └── main.tf
│   ├── ecr/
│   │   └── main.tf
│   ├── lambda/
│   │   └── main.tf
│   └── apigateway/
│       └── main.tf
├── docker/
│   ├── Dockerfile
│   ├── appointment-service.js
│   ├── handler.js
│   └── package.json
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
└── postman_collection.json
```

```css
appointment-service-infra/
├── main.tf              # Wires all modules together
├── variables.tf         # Root variables
├── outputs.tf           # Root outputs (API Gateway URL, etc.)
├── provider.tf          # AWS provider config
├── modules/
│   ├── vpc/
│   │   └── main.tf
│   ├── iam/
│   │   └── main.tf
│   ├── ecr/
│   │   └── main.tf
│   ├── lambda/
│   │   └── main.tf
│   └── apigateway/
│       └── main.tf
├── docker/
│   ├── Dockerfile
│   ├── package.json
│   ├── appointment-service.js
│   └── handler.js
├── .github/
│   └── workflows/
│       └── docker-build.yml
├── postman_collection.json
└── README.md
```

---

Got it ✅
You want your current **single big `main.tf`** converted into **modular Terraform code**, with proper `variables.tf` and `outputs.tf`.

Here’s how I’ll structure it:

---

## 📂 Folder Structure (modular)

```
terraform-project/
│── main.tf
│── variables.tf
│── outputs.tf
│── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── lambda/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── apigateway/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

---

## 🔹 Root `main.tf`

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
  enable_xray = var.enable_xray
}

module "lambda" {
  source = "./modules/lambda"
  create_lambda     = var.create_lambda
  lambda_image_uri  = var.lambda_image_uri
  lambda_memory     = var.lambda_memory
  lambda_timeout    = var.lambda_timeout
  enable_xray       = var.enable_xray
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security.lambda_sg_id
  lambda_role_arn    = module.iam.lambda_role_arn
}

module "apigateway" {
  source = "./modules/apigateway"
  create_lambda   = var.create_lambda
  aws_region      = var.aws_region
  account_id      = data.aws_caller_identity.current.account_id
  lambda_arn      = module.lambda.lambda_arn
}
```

---

## 🔹 Root `variables.tf`

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "create_lambda" {
  type        = bool
  default     = false
  description = "Set to true after pushing image. Controls Lambda & API creation."
}

variable "lambda_image_uri" {
  type        = string
  default     = ""
  description = "ECR image URI for Lambda (required when create_lambda = true)."
}

variable "lambda_memory" {
  type    = number
  default = 512
}

variable "lambda_timeout" {
  type    = number
  default = 15
}

variable "enable_xray" {
  type    = bool
  default = true
}
```

---

## 🔹 Root `outputs.tf`

```hcl
output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "api_endpoint" {
  value = module.apigateway.api_endpoint
}
```

---

## 🔹 Example Module: `modules/vpc/main.tf`

```hcl
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "appt-vpc" }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, 100 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "private-${count.index + 1}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = { Name = "nat-gw" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### `modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
```

---

👉 I didn’t expand all modules here (security, ecr, iam, lambda, apigateway), but I can fully write **all 6 modules** with `variables.tf`, `main.tf`, and `outputs.tf` if you want the **ready-to-run modular repo**.

Do you want me to **generate a full zip folder** (with all module code written out), like I did last time?




---

Yes 👍 — in Terraform you can pass variables in multiple ways when running `terraform apply`.

Since we modularized your project, the **root `variables.tf`** already defines these vars:

* `aws_region` (default `"us-east-1"`)
* `create_lambda` (default `false`)
* `lambda_image_uri` (default `""`)
* `lambda_memory` (default `512`)
* `lambda_timeout` (default `15`)
* `enable_xray` (default `true`)

---

## 🔹 1. First run (infra only, no Lambda/API)

```sh
terraform init
terraform apply -auto-approve
```

👉 This uses defaults → creates VPC, subnets, SG, ECR, IAM, but **skips Lambda & API** because `create_lambda = false`.

---

## 🔹 2. Run with custom variables via `-var`

When you’re ready to deploy Lambda & API:

```sh
terraform apply \
  -var="create_lambda=true" \
  -var="lambda_image_uri=595673262064.dkr.ecr.us-east-1.amazonaws.com/appointment-service:abcd123" \
  -var="lambda_memory=1024" \
  -var="lambda_timeout=30" \
  -auto-approve
```

---

## 🔹 3. Using environment variables (`TF_VAR_*`)

Instead of `-var=...`, you can export:

```sh
export TF_VAR_create_lambda=true
export TF_VAR_lambda_image_uri=595673262064.dkr.ecr.us-east-1.amazonaws.com/appointment-service:abcd123
export TF_VAR_lambda_memory=1024
export TF_VAR_lambda_timeout=30
```

Then just run:

```sh
terraform apply -auto-approve
```

---

## 🔹 4. Using a `.tfvars` file

Create `dev.tfvars`:

```hcl
aws_region      = "us-east-1"
create_lambda   = true
lambda_image_uri = "595673262064.dkr.ecr.us-east-1.amazonaws.com/appointment-service:abcd123"
lambda_memory   = 1024
lambda_timeout  = 30
enable_xray     = true
```

Run:

```sh
terraform apply -var-file="dev.tfvars" -auto-approve
```

---

✅ Recommended flow for you:

1. Run once with defaults → infra only.
2. Build & push Docker image to ECR.
3. Run again with `-var="create_lambda=true"` and `-var="lambda_image_uri=..."`.

---

Do you want me to also write a **step-by-step sample command sequence** (from `docker build` → `docker push` → `terraform apply`) so it’s a copy-paste ready workflow?

----
