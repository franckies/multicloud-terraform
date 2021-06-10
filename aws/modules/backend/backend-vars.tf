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
  description = "The ARN of the dynamoDB table."
}

variable "vpc_endpoint_id" {
  description = "The VPC endpoint associated to the apigw."
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The region where the associated VPC is."
}

variable "stage_name" {
  type        = string
  default     = "dev"
  description = "The stage name of the endpoint."
}