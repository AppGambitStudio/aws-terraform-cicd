data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "cloudtrail_logs" {
  name                          = "${var.cloudtrail_logs_name}"
  s3_bucket_name                = "${aws_s3_bucket.s3_bucket_cloudtrail.id}"
  s3_key_prefix                 = "${var.environment}"
  include_global_service_events = false
}

resource "aws_s3_bucket" "s3_bucket_cloudtrail" {
  bucket        = "${var.cloudtrail_bucket_name}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.cloudtrail_bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.cloudtrail_bucket_name}/${var.environment}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "uploads_access_block" {
  bucket = "${aws_s3_bucket.s3_bucket_cloudtrail.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
