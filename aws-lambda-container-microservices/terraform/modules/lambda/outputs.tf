output "lambda_arn" {
  value = aws_lambda_function.container.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.container.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.container.function_name
}
