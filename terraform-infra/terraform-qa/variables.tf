# =========================
# General Variables
# =========================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# =========================
# VPC Variables
# =========================
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "Public subnet CIDR for AZ1"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "Public subnet CIDR for AZ2"
  type        = string
}

variable "private_subnet_az1_cidr" {
  description = "Private subnet CIDR for AZ1"
  type        = string
}

variable "private_subnet_az2_cidr" {
  description = "Private subnet CIDR for AZ2"
  type        = string
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
}

# =========================
# ALB / ECS Variables
# =========================
variable "alb_additional_ingress_rules" {
  description = "Additional ingress rules for ALB security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
  }))
  default = []
}

variable "services" {
  description = "Map of ECS services to deploy"
  type        = any
}
# variable "services" {
#   description = "Map of ECS services to deploy"
#   type = map(object({
#     listener_rule_priority = number
#     host_headers           = list(string)
#     task_cpu               = string
#     task_memory            = string
#     task_definition_file   = string
#     desired_count          = number
#     container_name         = string
#     target_group_name      = optional(string)
#     service_name           = optional(string)
#     task_definition_family = optional(string)
#     task_role_arn          = optional(string)
#     health_check_path      = optional(string)
#     volumes                = optional(list(any))

#     # Autoscaling
#     min_capacity           = optional(number)
#     max_capacity           = optional(number)
#     target_cpu_value       = optional(number)
#   }))
# }

# =========================
# S3 / CloudFront Variables
# =========================
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "oai_comment" {
  description = "CloudFront OAI comment"
  type        = string
}

variable "cloudfront_origin_id" {
  description = "CloudFront origin ID"
  type        = string
}

variable "cloudfront_distribution_name" {
  description = "CloudFront distribution name"
  type        = string
}

# variable "cloudfront_aliases" {
#   description = "Alternate domain names (CNAMEs) for CloudFront"
#   type        = list(string)
#   default     = []
# }

# variable "certificate_arn" {
#   description = "ACM certificate ARN for CloudFront"
#   type        = string
# }
# =========================
# Common Tags
# =========================
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

