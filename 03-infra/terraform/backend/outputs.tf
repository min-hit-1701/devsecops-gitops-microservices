output "aws_region" {
  description = "AWS region used for backend"
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

output "backend_tf_snippet" {
  description = "Snippet to copy into Terraform backend config"
  value = <<-EOT
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.tf_state.bucket}"
    key            = "envs/dev/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.tf_lock.name}"
    encrypt        = true
  }
}
EOT
}
