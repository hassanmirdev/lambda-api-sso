module "lambda" {
  source = "../../modules/lambda"
}

module "cognito" {
  source = "../../modules/cognito"
}
