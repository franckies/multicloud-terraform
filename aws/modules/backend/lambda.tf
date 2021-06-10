################################################################################
# Lambda backend, API Gateway
################################################################################

# Policy to allow lambda access dynamodb table
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.role_for_LDC.id

  #policy =  file("${path.module}/policy.json")
  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource" : var.dynamo_table_arn
      }
    ]
  })
}


resource "aws_iam_role" "role_for_LDC" {
  name = "myrole"

  #assume_role_policy =  file("${path.module}/assume_role_policy.json")
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# backend-app.handler is the name of the property under which the handler function
# was exported in backend-app.js
resource "aws_lambda_function" "counterUpdate" {

  function_name    = "counterUpdate"
  filename         = "backend-app.zip"
  source_code_hash = filebase64sha256("backend-app.zip")
  role             = aws_iam_role.role_for_LDC.arn
  handler          = "backend-app.handler"
  runtime          = "nodejs12.x"

  #  vpc_config {
  #   subnet_ids         = [aws_subnet.subnet_for_lambda.id]
  #   security_group_ids = [aws_security_group.sg_for_lambda.id]
  # }
}


# The REST API is the container for all the other API Gateway objects we will 
# create.
resource "aws_api_gateway_rest_api" "apiLambda" {
  name   = "counter-app-api"
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

  integration_http_method = "POST"
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
