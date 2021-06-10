output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.apiLambda.id}-${var.vpc_endpoint_id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"
}