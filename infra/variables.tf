variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "codecommit_repository_name" {
  default = "misfit"
}

variable "s3_tfstate_bucket" {
  default = "mike-tfstate-bucket-0012"
}

variable "dynamo_db_table_name" {
  default = "mike-tflock-0012"
}

variable "cognito_user_pool" {
  default = "misfits-pool"
}

variable "pipeline_s3_bucket" {
  default = "misfits-bucket-mike-00128"
}


data "aws_codecommit_repository" "misfit" {
  repository_name = "${var.codecommit_repository_name}"
}