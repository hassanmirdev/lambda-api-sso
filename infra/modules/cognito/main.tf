resource "aws_cognito_user_pool" "my_cognito_pool" {
  name = "my_cognito_pool"
  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_client" "my_userpool_client" {
  name                                 = "my_userpool_client"
  user_pool_id                         = aws_cognito_user_pool.my_cognito_pool.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["aws.cognito.signin.user.admin"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  callback_urls                        = ["https://example.com"]
  prevent_user_existence_errors        = "ENABLED"
}

resource "aws_cognito_user" "my_user" {
  user_pool_id = aws_cognito_user_pool.my_cognito_pool.id
  username     = var.username
  password     = var.password
}

resource "aws_api_gateway_authorizer" "apigw_authorizer" {
  name          = "apigw_authorizer"
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.my_cognito_pool.arn]
}

# Run following on command line before terraform apply command
#export TF_VAR_username=test
#export TF_VAR_password=your_password
















