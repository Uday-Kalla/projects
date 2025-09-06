variable "project_name" { type = string }
variable "lambda_image_uri" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "role_arn" { type = string }