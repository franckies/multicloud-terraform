output "table_arn" {
  description = "The ARN of the dynamoDB table."
  value       = module.dynamodb_table.dynamodb_table_arn
}