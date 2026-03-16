# -------------------------
# General Variables
# -------------------------
variable "environment" {
  description = "Environment name (e.g., prod, stage, dev, qa)"
  type        = string
  validation {
    condition     = can(regex("^(prod|stage|dev|qa)$", var.environment))
    error_message = "Environment must be prod, stage, qa, or dev."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# -------------------------
# VPC & Network Variables
# -------------------------
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "alb_subnet_ids" {
  description = "List of subnet IDs for Application Load Balancer"
  type        = list(string)
}

variable "ecs_service_subnet_ids" {
  description = "List of subnet IDs for ECS services"
  type        = list(string)
}

# -------------------------
# ALB Security Group Variables
# -------------------------
variable "alb_security_group_name" {
  description = "Name of the ALB security group"
  type        = string
}

variable "alb_security_group_description" {
  description = "Description of the ALB security group"
  type        = string
}

variable "allow_cloudfront" {
  description = "Allow traffic from CloudFront on HTTPS port"
  type        = bool
  default     = true
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

# variable "https_port" {
#   description = "HTTPS port"
#   type        = number
#   default     = 443
# }

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

# -------------------------
# ECS Security Group Variables
# -------------------------
variable "ecs_security_group_name" {
  description = "Name of the ECS service security group"
  type        = string
}

variable "ecs_security_group_description" {
  description = "Description of the ECS service security group"
  type        = string
}

variable "container_port" {
  description = "Container port for ECS services"
  type        = number
  default     = 8000
}

variable "ecs_additional_ingress_rules" {
  description = "Additional ingress rules for ECS security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = optional(list(string))
    cidr_blocks     = optional(list(string))
  }))
  default = []
}

# -------------------------
# Application Load Balancer Variables
# -------------------------
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "alb_internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = true
}

# -------------------------
# Target Group Variables
# -------------------------
variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for target group"
  type        = string
  default     = "ip"
}

variable "enable_stickiness" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration for stickiness in seconds"
  type        = number
  default     = 86400
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP status code matcher for health check"
  type        = string
  default     = "200-399"
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 60
}

# variable "ssl_policy" {
#   description = "SSL policy for HTTPS listener"
#   type        = string
#   default     = "ELBSecurityPolicy-2016-08"
# }


# variable "https_listener_default_action" {
#   description = "Default action for HTTPS listener"
#   type        = string
#   default     = "fixed-response"
# }

# variable "https_fixed_response_content_type" {
#   description = "Content type for HTTPS fixed response"
#   type        = string
#   default     = "text/plain"
# }

# variable "https_fixed_response_message_body" {
#   description = "Message body for HTTPS fixed response"
#   type        = string
#   default     = "Not Found"
# }

# variable "https_fixed_response_status_code" {
#   description = "Status code for HTTPS fixed response"
#   type        = string
#   default     = "404"
# }

# -------------------------
# ECS Cluster Variables
# -------------------------
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = true
}

# -------------------------
# IAM Role Variables
# -------------------------
variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "ecs_task_assume_role_policy" {
  description = "Assume role policy for ECS task execution role"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}

variable "ecs_task_execution_policy_arns" {
  description = "List of policy ARNs to attach to ECS task execution role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]
}

# -------------------------
# Task Definition Variables
# -------------------------
variable "task_network_mode" {
  description = "Network mode for task definition"
  type        = string
  default     = "awsvpc"
}

variable "task_requires_compatibilities" {
  description = "Launch type requirements for task definition"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "enable_runtime_platform" {
  description = "Enable runtime platform configuration"
  type        = bool
  default     = true
}

variable "runtime_platform_os" {
  description = "Operating system for runtime platform"
  type        = string
  default     = "LINUX"
}

variable "runtime_platform_cpu_arch" {
  description = "CPU architecture for runtime platform"
  type        = string
  default     = "X86_64"
}

# -------------------------
# ECS Service Variables
# -------------------------
variable "launch_type" {
  description = "Launch type for ECS service"
  type        = string
  default     = "FARGATE"
}

variable "assign_public_ip" {
  description = "Assign public IP to ECS tasks"
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = true
}

variable "enable_deployment_circuit_breaker" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

# -------------------------
# Services Configuration (PATH-BASED)
# -------------------------
variable "services" {
  description = "Map of services to deploy with path-based routing"
  type = map(object({
    listener_rule_priority = number
    path_patterns          = list(string)
    task_cpu               = string
    task_memory            = string
    task_definition_file   = string
    desired_count          = number
    container_name         = string
    # Add these for autoscaling
    min_capacity           = optional(number, 1)
    max_capacity           = optional(number, 3)
    target_cpu_value       = optional(number, 70)
    target_group_name      = optional(string)
    service_name           = optional(string)
    task_definition_family = optional(string)
    task_role_arn          = optional(string)
    health_check_path      = optional(string)
    volumes                = optional(list(any))
  }))
}

# -------------------------
# Common Tags
# -------------------------
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
