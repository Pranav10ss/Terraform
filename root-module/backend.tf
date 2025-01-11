resource "aws_s3_bucket" "backend" {
  bucket = "terraform-statefile-backend-project"
  tags = var.tags
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "backend-tf.statefile"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

terraform {
  backend "s3" {
    bucket = "terraform-statefile-backend-project"
    key    = "backend/project/tf.state"
    region = "us-east-1"
    dynamodb_table = "backend-tf.statefile"
  }
}
