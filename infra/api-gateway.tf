data "aws_cognito_user_pools" "misfits_api" {
  name = "${var.cognito_user_pool}"
}

resource "aws_api_gateway_rest_api" "misfits" {
  name = "misfits"
}

resource "aws_api_gateway_resource" "misfits_proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.misfits.id}"
  parent_id   = "${aws_api_gateway_rest_api.misfits.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "misfits" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = "${aws_api_gateway_rest_api.misfits.id}"
  provider_arns = "${data.aws_cognito_user_pools.misfits_api.arns}"
}

resource "aws_api_gateway_method" "any" {
  rest_api_id   = "${aws_api_gateway_rest_api.misfits.id}"
  resource_id   = "${aws_api_gateway_resource.misfits_proxy.id}"
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.misfits.id}"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "test" {
  rest_api_id = "${aws_api_gateway_rest_api.misfits.id}"
  resource_id = "${aws_api_gateway_resource.misfits_proxy.id}"
  http_method = "${aws_api_gateway_method.any.http_method}"

  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_alb.main.dns_name}/{proxy}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "misfits_prod" {
  depends_on = ["aws_api_gateway_integration.test"]

  rest_api_id = "${aws_api_gateway_rest_api.misfits.id}"
  stage_name  = "prod"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.misfits.id}"
  resource_id = "${aws_api_gateway_resource.misfits_proxy.id}"
  http_method = "${aws_api_gateway_method.any.http_method}"
  status_code = "200"
}