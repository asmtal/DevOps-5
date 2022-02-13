provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "kal-cicd-state"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "kal-cicd-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}