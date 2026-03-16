# -------------------------
# S3 Bucket
# -------------------------
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = var.common_tags
}

# -------------------------
# S3 Bucket Ownership Controls
# -------------------------
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = var.object_ownership
  }
}

# -------------------------
# S3 Bucket Versioning
# -------------------------
resource "aws_s3_bucket_versioning" "main" {

  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------
# S3 Bucket Server-Side Encryption
# -------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {

  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
    bucket_key_enabled = var.enable_bucket_key
  }
}

# -------------------------
# S3 Bucket Public Access Block
# -------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# -------------------------
# CloudFront Origin Access Identity
# -------------------------
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = var.oai_comment
}

# -------------------------
# S3 Bucket Policy with cloudfront
# -------------------------
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAIAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.main.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.main]
}

# -------------------------
# CloudFront Distribution
# -------------------------
resource "aws_cloudfront_distribution" "main" {
  enabled = var.cloudfront_enabled
  comment = var.cloudfront_distribution_name

  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = var.cloudfront_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    target_origin_id       = var.cloudfront_origin_id
    viewer_protocol_policy = var.viewer_protocol_policy

    forwarded_values {
      query_string = var.forward_query_string

      cookies {
        forward = var.forward_cookies
      }

      headers = var.forward_headers
    }

  }

  # Custom Error Response - Primary
  custom_error_response {
    error_code            = var.custom_error_code
    response_code         = var.custom_response_code
    error_caching_min_ttl = var.error_caching_min_ttl
    response_page_path    = var.error_response_page_path
  }

  #Geo Restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # Aliases
  aliases = var.cloudfront_aliases

  # SSL/TLS Certificate
  #viewer_certificate {
  # cloudfront_default_certificate = var.use_default_certificate
  #acm_certificate_arn            = var.acm_certificate_arn
  # ssl_support_method             = var.ssl_support_method
  #minimum_protocol_version       = var.minimum_protocol_version
  #}

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.common_tags

  depends_on = [aws_s3_bucket.main]
}
 