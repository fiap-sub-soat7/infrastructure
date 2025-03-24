resource "aws_cognito_user_pool" "t75-user_pool" {
  name = "t75-user_pool"

  alias_attributes = ["preferred_username"]  # to use Document (CPF) as login user

  password_policy {
    minimum_length = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers = true
    require_symbols = true
  }

  mfa_configuration = "OFF"

}

resource "aws_cognito_user_pool_client" "t75-user_pool_client" {
  name = "t75-user_pool_client"
  user_pool_id = aws_cognito_user_pool.t75-user_pool.id
  # generate_secret = true
  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = [
    "USER_PASSWORD_AUTH",
  ]

  access_token_validity = 1
  id_token_validity = 1

}

resource "aws_cognito_user_pool_domain" "t75-user_pool_domain" {
  domain = "vehicle-app-identity-service"
  user_pool_id = aws_cognito_user_pool.t75-user_pool.id
}

resource "aws_lambda_function" "t75-fn_identity" {
  function_name = "fn-identity"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.t75-ecr_ms_client.repository_url}:latest"

  role = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"

  memory_size = 128
  timeout = 10

  environment {
    variables = {
      UserPoolId = aws_cognito_user_pool.t75-user_pool.id
      ClientId = aws_cognito_user_pool_client.t75-user_pool_client.id
    }
  }
}

resource "aws_api_gateway_resource" "t75-ag_resource_identity" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id
  parent_id = aws_api_gateway_rest_api.t75-api_gateway.root_resource_id
  path_part = "identity"
}

resource "aws_api_gateway_method" "t75-ag_fn_identity_post" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id
  resource_id = aws_api_gateway_resource.t75-ag_resource_identity.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "t75-fn_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id
  resource_id = aws_api_gateway_resource.t75-ag_resource_identity.id
  http_method = "POST"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.t75-fn_identity.arn}/invocations"
}

resource "aws_lambda_permission" "t75-fn_identity_ag" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.t75-fn_identity.function_name
}
