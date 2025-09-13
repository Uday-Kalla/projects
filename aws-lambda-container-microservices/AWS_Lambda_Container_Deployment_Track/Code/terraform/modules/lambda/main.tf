variable "ecr_repo_url" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

resource "aws_lambda_function" "appointment" {
  function_name = "appointment-service-lambda"
  package_type  = "Image"
  role          = var.lambda_role_arn
  image_uri     = "${var.ecr_repo_url}:latest"
  timeout       = 30
  memory_size   = 512
}

output "function_name" {
  value = aws_lambda_function.appointment.function_name
}
