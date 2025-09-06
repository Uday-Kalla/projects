output "lambda_log_group" {
  value = aws_cloudwatch_log_group.lambda_log.name
}

output "apigw_log_group" {
  value = aws_cloudwatch_log_group.apigw_log.name
}
