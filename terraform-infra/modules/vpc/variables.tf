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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
  validation {
    condition     = can(cidrhost(var.public_subnet_az1_cidr, 0))
    error_message = "Public subnet AZ1 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
  validation {
    condition     = can(cidrhost(var.public_subnet_az2_cidr, 0))
    error_message = "Public subnet AZ2 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on instance launch in public subnets"
  type        = bool
  default     = true
}

variable "private_subnet_az1_cidr" {
  description = "CIDR block for private subnet in AZ1"
  type        = string
  validation {
    condition     = can(cidrhost(var.private_subnet_az1_cidr, 0))
    error_message = "Private subnet AZ1 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for private subnet in AZ2"
  type        = string
  validation {
    condition     = can(cidrhost(var.private_subnet_az2_cidr, 0))
    error_message = "Private subnet AZ2 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
 