output "table_arn" {
  description = "The ARN of the dynamoDB table"
  value       = aws_dynamodb_table.counter-app-table.arn
}