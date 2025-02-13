#1 Create Lambda Function
data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "lambda/index.js"
  output_path = "lambda/index.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = file("lambda-policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "yt_lambda_function" {
  filename         = "lambda/index.zip"
  function_name    = "DemoLambdaFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256

  environment {
    variables = {
      VIDEO_NAME = "Lambda Terraform Demo"
    }
  }
}

#2 Create API Gateway
resource "aws_api_gateway_rest_api" "yt_api" {
  name        = "yt-api"
  description = "API for Demo"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "yt_api_resource" {
  parent_id   = aws_api_gateway_rest_api.yt_api.root_resource_id
  path_part   = "demo-path"
  rest_api_id = aws_api_gateway_rest_api.yt_api.id
}

resource "aws_api_gateway_method" "yt_method" {
  resource_id   = aws_api_gateway_resource.yt_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.yt_api.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.apigw_authorizer.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  http_method             = aws_api_gateway_method.yt_method.http_method
  resource_id             = aws_api_gateway_resource.yt_api_resource.id
  rest_api_id             = aws_api_gateway_rest_api.yt_api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.yt_lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.yt_api.id
  stage_name  = "dev"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.yt_api_resource.id,
      aws_api_gateway_method.yt_method.id,
      aws_api_gateway_integration.lambda_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.yt_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.yt_api.execution_arn}/*/*/*"
}

output "invoke_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}