################################################################################
# DynamoDB
################################################################################
module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "counter-app-table"
  hash_key = "id"

  read_capacity  = 5
  write_capacity = 5

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
