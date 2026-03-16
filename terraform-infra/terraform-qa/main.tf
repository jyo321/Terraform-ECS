# -------------------------
# Local Variables
# -------------------------
locals {
  environment = terraform.workspace
}

# -------------------------
# VPC Module
# -------------------------
module "vpc" {
  source = "../modules/vpc"

  environment             = local.environment
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_az1_cidr  = var.public_subnet_az1_cidr
  public_subnet_az2_cidr  = var.public_subnet_az2_cidr
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_az2_cidr = var.private_subnet_az2_cidr
  availability_zone_1     = var.availability_zone_1
  availability_zone_2     = var.availability_zone_2
  common_tags             = var.common_tags
}

# -------------------------
# ECS Module
# -------------------------
module "ecs" {
  source = "../modules/ecs"

  environment  = local.environment
  project_name = var.project_name
  # VPC Configuration
  vpc_id                 = module.vpc.vpc_id
  alb_subnet_ids         = module.vpc.public_subnet_ids
  ecs_service_subnet_ids = module.vpc.private_subnet_ids

  # Security Group Configuration
  alb_security_group_name        = "${var.project_name}-${local.environment}-alb-sg"
  alb_security_group_description = "Security group for ${var.project_name} ${local.environment} ALB"
  ecs_security_group_name        = "${var.project_name}-${local.environment}-ecs-sg"
  ecs_security_group_description = "Security group for ${var.project_name} ${local.environment} ECS Service"

  # ALB Configuration
  alb_name = "${var.project_name}-${local.environment}"
  #alb_access_logs_bucket_name = "${var.project_name}-${local.environment}-alb-access-logs-tf"

  # ECS Cluster Configuration
  ecs_cluster_name = "${var.project_name}-${local.environment}"

  # IAM Role Configuration
  ecs_task_execution_role_name = "${var.project_name}-${local.environment}-ecs-task-execution-role"

  # Services Configuration
  services = var.services

  # Tags
  common_tags = var.common_tags

  depends_on = [module.vpc]
}

# -------------------------
# S3-CloudFront Module
# -------------------------
module "s3_cloudfront" {
  source = "../modules/s3-cloudfront"

  bucket_name                  = var.bucket_name
  oai_comment                  = var.oai_comment
  cloudfront_origin_id         = var.cloudfront_origin_id
  cloudfront_distribution_name = var.cloudfront_distribution_name
  # cloudfront_aliases          = var.cloudfront_aliases
  # acm_certificate_arn         = var.certificate_arn
  #public_bucket_name          = "${var.project_name}-${local.environment}-profiles"
  common_tags = var.common_tags
}

