/*====
S3 Buckets
======*/

resource "aws_s3_bucket" "assets" {
  bucket = "${var.uploads_bucket_prefix}-${var.environment}"
  acl    = "private"

  tags = {
    Name        = "${var.environment}-s3-assets-bucket"
    Environment = "${var.environment}"
  }

  lifecycle_rule {
    enabled = true

    tags = {
      "rule"      = "uploads"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets_access_block" {
  bucket = "${aws_s3_bucket.assets.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
