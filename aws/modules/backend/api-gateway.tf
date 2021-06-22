################################################################################
# API Gateway
################################################################################
# The REST API is the container for all the other API Gateway objects we will 
# create.
resource "aws_api_gateway_rest_api" "apiLambda" {
  name = "counter-app-api"
}


resource "aws_api_gateway_resource" "counter-app-resource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "counter-app-resource"

}


resource "aws_api_gateway_method" "post-method" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id

  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get-method" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id

  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "post-method" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id
    http_method   = "POST"
    status_code   = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.post-method]
}

resource "aws_api_gateway_method_response" "get-method" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id
    http_method   = "GET"
    status_code   = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.get-method]
}


resource "aws_api_gateway_integration" "post-lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id
  http_method = aws_api_gateway_method.post-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.counterUpdate.invoke_arn

}

resource "aws_api_gateway_integration" "get-lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.counter-app-resource.id
  http_method = aws_api_gateway_method.get-method.http_method

  integration_http_method = "POST" # https://github.com/hashicorp/terraform/issues/9271 Lambda requires POST as the integration type
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.counterUpdate.invoke_arn

}


resource "aws_api_gateway_deployment" "post-apideploy" {
  depends_on = [aws_api_gateway_integration.post-lambda-integration]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_deployment" "get-apideploy" {
  depends_on = [aws_api_gateway_integration.get-lambda-integration]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = var.stage_name
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counterUpdate.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/*"
}

# Enable CORS
module "example_cors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"

  api      = aws_api_gateway_rest_api.apiLambda.id
  resource = aws_api_gateway_resource.counter-app-resource.id

  methods = ["GET", "POST"]
}
