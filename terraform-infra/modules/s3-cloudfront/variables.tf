# -------------------------
# S3 Bucket Variables
# -------------------------
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "object_ownership" {
  description = "Object ownership setting"
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "enable_bucket_key" {
  description = "Enable S3 Bucket Key for encryption"
  type        = bool
  default     = true
}

# -------------------------
# Public Access Block Variables
# -------------------------
variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

# -------------------------
# CloudFront OAI Variables
# -------------------------
variable "oai_comment" {
  description = "Comment for CloudFront Origin Access Identity"
  type        = string
}

# -------------------------
# CloudFront Distribution Variables
# -------------------------
variable "cloudfront_origin_id" {
  description = "Origin ID for CloudFront distribution"
  type        = string
}

variable "cloudfront_enabled" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6 for CloudFront"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "cloudfront_distribution_name" {
  description = "Name/comment for CloudFront distribution"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_All"
}

variable "http_version" {
  description = "Maximum HTTP version"
  type        = string
  default     = "http2"
}

# -------------------------
# Cache Behavior Variables
# -------------------------
variable "allowed_methods" {
  description = "Allowed HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "Cached HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Enable automatic compression"
  type        = bool
  default     = true
}

variable "viewer_protocol_policy" {
  description = "Viewer protocol policy"
  type        = string
  default     = "redirect-to-https"
}

variable "forward_query_string" {
  description = "Forward query strings to origin"
  type        = bool
  default     = false
}

variable "forward_cookies" {
  description = "Forward cookies to origin"
  type        = string
  default     = "none"
}

variable "forward_headers" {
  description = "Headers to forward to origin"
  type        = list(string)
  default     = []
}

# -------------------------
# TTL Variables
# -------------------------
variable "min_ttl" {
  description = "Minimum TTL in seconds"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL in seconds"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL in seconds"
  type        = number
  default     = 86400
}

# -------------------------
# Custom Error Response Variables
# -------------------------
variable "custom_error_code" {
  description = "Custom error code"
  type        = number
  default     = 403
}

variable "custom_response_code" {
  description = "Custom response code"
  type        = number
  default     = 200
}

variable "error_caching_min_ttl" {
  description = "Error caching minimum TTL"
  type        = number
  default     = 300
}

variable "error_response_page_path" {
  description = "Error response page path"
  type        = string
  default     = "/index.html"
}

variable "additional_error_responses" {
  description = "Additional custom error responses"
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
  default = []
}

# -------------------------
# Geo Restriction Variables
# -------------------------
variable "geo_restriction_type" {
  description = "Geo restriction type"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "Country codes for geo restriction"
  type        = list(string)
  default     = []
}

# -------------------------
# SSL/TLS Variables
# -------------------------
variable "cloudfront_aliases" {
  description = "Alternate domain names (CNAMEs) for CloudFront"
  type        = list(string)
  default     = []
}

variable "use_default_certificate" {
  description = "Use default CloudFront certificate"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

variable "ssl_support_method" {
  description = "SSL support method"
  type        = string
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

# -------------------------
# Tags
# -------------------------
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}