# projects
AWS Lambda container microservices

```graphql
microservices-project/
│
├── patient-service/
│   ├── patient-service.js         # Lambda handler for patient microservice
│   ├── package.json               # Dependencies
│   ├── Dockerfile                 # Optimized for AWS Lambda
│
├── appointment-service/
│   ├── appointment-service.js     # Lambda handler for appointment microservice
│   ├── package.json               # Dependencies
│   ├── Dockerfile                 # Optimized for AWS Lambda
│
├── terraform/
│   ├── main.tf                    # VPC, ECR, Lambda, API Gateway
│   ├── provider.tf                # AWS provider
│   ├── versions.tf                # Terraform & AWS provider version lock
│   ├── backend.tf                 # Remote state config (S3 + DynamoDB)
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Outputs (API endpoint, ARNs, repo URLs)
│   ├── terraform.tfvars           # Default values for variables
│
├── scripts/
│   └── push-images.sh             # Bash script to build & push Docker images
│
└── .github/
    └── workflows/
        └── deploy.yml             # GitHub Actions workflow for CI/CD
```