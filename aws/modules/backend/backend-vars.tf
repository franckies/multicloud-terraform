variable "vpc_id" {
  description = "The ID of the VPC."
}

variable "public_subnets" {
  description = "The public subnets ids."
}

variable "intra_subnets" {
  description = "The intra subnets ids."
}

variable "private_subnets" {
  description = "The private subnets ids."
}

variable "dynamo_table_arn" {
  description = "The ARN of the dynamoDB table"
}