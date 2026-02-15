resource "aws_s3_bucket" "b" {
  bucket = "${var.project_name}-${var.environment}-${var.bucket_name}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.bucket_name}"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.b.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
