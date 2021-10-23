terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.63.0"
    }

    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}



resource "aws_s3_bucket" "estore_bucket" {
  bucket = "sj-estore-bucket"

  acl = "private"
  force_destroy = true
}

// dist making
data "archive_file" "lambda_estore_dist" {
  type = "zip"

  source_dir = "${path.module}/index"
  output_path = "${path.module}/index.zip"
}

// s3 bucket making
resource "aws_s3_bucket_object" "estore_bucket_object" {
  bucket = aws_s3_bucket.estore_bucket.id

  key = "index.zip"
  source = data.archive_file.lambda_estore_dist.output_path

  etag = filemd5(data.archive_file.lambda_estore_dist.output_path)
}

provider "aws" {
   region = "ap-south-1"
   access_key = ""
   secret_key = ""

}

resource "aws_dynamodb_table" "ddbtable" {
  name             = "myDB"
  hash_key         = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.role_for_LDC.id

  policy = file("policy.json")
}


resource "aws_iam_role" "role_for_LDC" {
  name = "myrole"

  assume_role_policy = file("assume_role_policy.json")

}



resource "aws_lambda_function" "myLambda" {

  function_name = "func"
  s3_bucket     = "sj-estore-bucket"
  s3_key        = "index.zip"
  role          = aws_iam_role.role_for_LDC.arn
  handler       = "index.handler"
  runtime       = "nodejs12.x"
}
