module "lambda" {
  source = "../../modules/lambda"
}

module "cognito" {
  source = "../../modules/cognito"
  rest_api_id  = module.lambda.rest_api_id
}
