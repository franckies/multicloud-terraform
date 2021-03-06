################################################################################
# Roles for backend lambda
################################################################################
# Role for lambda function
resource "aws_iam_role" "counter-app-lambda-role" {
  name = "counter-app-lambda-role"

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

# Policy to allow lambda access dynamodb table
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.counter-app-lambda-role.id

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

# Policy to allow lambda to be deployed in VPC
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.counter-app-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

################################################################################
# Security groups for backend lambda
################################################################################
resource "aws_security_group" "counter-app-lambda-sg" {
  name = "${var.prefix_name}-lambda-sg"

  description = "Only egress is needed"
  vpc_id      = var.vpc_id

  egress {
    from_port = var.http_port
    to_port   = var.http_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = var.https_port
    to_port   = var.https_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.prefix_name}-lambda-sg"
    Terraform   = "true"
    Environment = "dev"
  }
}

################################################################################
# Backend lambda function
################################################################################
# Generate ZIP from js file
data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "${path.module}/backend-app"
  output_path = "${path.module}/backend-app.zip"
}

# backend-app.handler is the name of the property under which the handler function
# was exported in backend-app.js
resource "aws_lambda_function" "counterUpdate" {

  function_name    = "counterUpdate"
  filename         = data.archive_file.file_function_app.output_path
  source_code_hash = filebase64sha256(data.archive_file.file_function_app.output_path)
  role             = aws_iam_role.counter-app-lambda-role.arn
  handler          = "backend-app.handler"
  runtime          = "nodejs12.x"

  vpc_config {
    subnet_ids         = var.intra_subnets
    security_group_ids = [aws_security_group.counter-app-lambda-sg.id]
  }

  environment {
    variables = {
      azure_api = "${var.azure_api_url}"
    }
  }

}