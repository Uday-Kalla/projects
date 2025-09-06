# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-lambda-log"
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "apigw_log" {
  name              = "/aws/apigateway/${var.project_name}-api"
  retention_in_days = 14
}

# Enable API Gateway access logging
resource "aws_apigatewayv2_stage" "logging" {
  api_id      = var.api_id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_log.arn
    format = jsonencode({
      requestId     = "$context.requestId"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      responseLength= "$context.responseLength"
    })
  }
}
