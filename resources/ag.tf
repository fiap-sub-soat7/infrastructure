resource "aws_api_gateway_rest_api" "t75-api_gateway" {
  name = "t75-api_gateway"
}

resource "aws_api_gateway_resource" "t75-ag_resouce_lb" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id
  parent_id   = aws_api_gateway_rest_api.t75-api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "t75-ag_lg" {
  rest_api_id   = aws_api_gateway_rest_api.t75-api_gateway.id
  resource_id   = aws_api_gateway_resource.t75-ag_resouce_lb.id
  http_method   = "ANY"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "t75-ag_lb_integration" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id
  resource_id = aws_api_gateway_resource.t75-ag_resouce_lb.id
  http_method = "ANY"
  integration_http_method = "ANY"
  type = "HTTP_PROXY"

  uri = "http://${aws_lb.t75-lb_ingress.dns_name}/"

  depends_on = [ 
    aws_api_gateway_rest_api.t75-api_gateway,
    aws_api_gateway_resource.t75-ag_resouce_lb
   ]
}

resource "aws_api_gateway_stage" "tg-ag_stage" {
  deployment_id = aws_api_gateway_deployment.tg-ag_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.t75-api_gateway.id
  stage_name    = "v4"
}

resource "aws_api_gateway_deployment" "tg-ag_deployment" {
  rest_api_id = aws_api_gateway_rest_api.t75-api_gateway.id

  lifecycle {
    create_before_destroy = true
  }



  depends_on = [ 
    aws_api_gateway_method.t75-ag_lg,
    aws_api_gateway_integration.t75-ag_lb_integration,
  ]
}
