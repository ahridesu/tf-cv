resource "aws_s3_bucket" "website" {
  bucket = "cv-ariana-goncalves"

  tags = {
    Name        = "staticbucket"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # Important: Wait for CloudFront distribution before applying policy
  depends_on = [aws_cloudfront_distribution.website]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.website.id}"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_s3_object" "index" {
  for_each = fileset("../website/", "*")

  bucket       = aws_s3_bucket.website.id
  key          = each.value
  source       = "../website/${each.value}"
  content_type = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  content_encoding = "utf-8"
}

resource "aws_cloudfront_origin_access_control" "website_oac" {
  name                               = "oac-cv-ariana-goncalves"
  description                        = "OAC for static site bucket"
  signing_behavior                   = "always"
  signing_protocol                   = "sigv4"
  origin_access_control_origin_type = "s3"
}

locals {
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
  }
}
