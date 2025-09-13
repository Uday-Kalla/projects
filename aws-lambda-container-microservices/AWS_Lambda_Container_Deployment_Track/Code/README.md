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
