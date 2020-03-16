terraform {
  required_version = ">=0.12.16"

  # Uncomment this section once you're ready to store shared state
  # i.e. S3 bucket and DynamoDB table has been created
  # backend "s3" {
  #   bucket         = "mike-tfstate-bucket-0012"
  #   key            = "terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "mike-tflock-0012"
  #   encrypt        = true
  # }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "${var.s3_tfstate_bucket}"
  force_destroy = true
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}


resource "aws_dynamodb_table" "tf_lock_state" {
  name = "${var.dynamo_db_table_name}"

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}