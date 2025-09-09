Outputs:

api_endpoint = "https://ecp36ydcc2.execute-api.us-east-1.amazonaws.com/"
private_subnets = [
  "subnet-0266f6a538d656dcc",
  "subnet-017920db42b799284",
]
public_subnets = [
  "subnet-09ea098a9ea66ef9d",
  "subnet-0bac5667ae23c99a6",
]
s3_bucket = "healthcare-deploy01"
vpc_id = "vpc-0e7c7e81aee5d9ac0"

```sh
remote: error: Trace: ef833894b26bb27e6d113844df4f70388f206b412dba126798b91fb3ab7d3a24
remote: error: See https://gh.io/lfs for more information.
remote: error: File aws-lambda-container-microservices/resource_creation/.terraform/providers/registry.terraform.io/hashicorp/aws/6.12.0/windows_386/terraform-provider-aws_v6.12.0_x5.exe is 724.68 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
To https://github.com/Uday-Kalla/projects.git
 ! [remote rejected] main -> main (pre-receive hook declined)
error: failed to push some refs to 'https://github.com/Uday-Kalla/projects.git'
PS E:\aws\VS Code\projects\aws-lambda-container-microservices>
```

```sh
Id CommandLine
  -- -----------
   1 try { . "c:\Users\udayk\AppData\Local\Programs\Microsoft VS Code\resources\app\out\vs\workbench\contrib\terminal\common\scripts\shellIntegration.ps1" } catch {}     
   2 cd .\projects\aws-lambda-container-microservices\resource_creation\
   3 clear
   4 terraform destroy
   5 clear
   6 terrafrom validate
   7 terraform destroy
   8 clear
   9 terrafrom -help
  10 terraform --version
  11 terraform validate
  12 terraform init
  13 clear
  14 terraform validate
  15 terraform plan
  16 terraform apply
  17 clear
  18 cd ../
  19 git ststu
  20 git status
  21 git add .
  22 git add .
  23 git commit -m "Terraform setup"
  24 git push
  25 clear
  26 docker login
  27 clear
  28 clear
  29 cd .\services\
  30 cd .\appointment-service\
  31 ls
  32 clear
  39 aws ecr create-repository --repository-name healthcare-appointment --region us-east-1
  40 docker build -t appointment-service .
  41 docker build -t appointment-service Dockerfile
  42 clear
  43 ls
  44 docker build -t appointment-service Dockerfile
  45 docker info
  46 docker info
  47 docker run hello-world
  48 clear
  49 docker run hello-world
  50 docker run hello-world
  51 docker run hello-world
  52 docker run hello-world
  53 clear
  54 docker run hello-world
  55 clear
  56 docker build -t appointment-service .
  57 setx DOCKER_BUILDKIT 0
  58 docker build -t appointment-service .
  59 clear
  60 docker build -t appointment-service .
  61 docker build -t appointment-service .
  62 clear
```
