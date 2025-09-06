resource "aws_lambda_function" "container" {
  function_name = "${var.project_name}-function"
  role          = var.role_arn
  package_type  = "Image"
  image_uri     = var.lambda_image_uri

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  memory_size = 512
  timeout     = 15
}

output "lambda_arn" {
  value = aws_lambda_function.container.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.container.invoke_arn
}
