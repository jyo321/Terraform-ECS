project_name = "test"
aws_region   = "us-east-1"

# VPC
vpc_cidr                = "10.2.0.0/16"
public_subnet_az1_cidr  = "10.2.1.0/24"
public_subnet_az2_cidr  = "10.2.2.0/24"
private_subnet_az1_cidr = "10.2.11.0/24"
private_subnet_az2_cidr = "10.2.12.0/24"
availability_zone_1     = "us-east-1a"
availability_zone_2     = "us-east-1b"

# Services
services = {
  backend = {
    listener_rule_priority = 100
    path_patterns          = ["/health/*"]
    task_cpu               = "256"
    task_memory            = "512"
    task_definition_file   = "task-definitions/backend.json"
    desired_count          = 1
    container_name         = "test-backend-qa"
    health_check_path      = "/health"
    # Autoscaling:
    min_capacity     = 1
    max_capacity     = 2
    target_cpu_value = 70
  }
}
# S3 / CloudFront
bucket_name                  = "test123qa-frontend"
oai_comment                  = "OAI for test CloudFront"
cloudfront_origin_id         = "test-s3-origin"
cloudfront_distribution_name = "test-cloudfront"
# cloudfront_aliases          = [""]
# certificate_arn             = "arn:aws:acm:us-east-1:060795928859:certificate/83896a3c-479f-462c-b3f8-cf74a5a29cd5"

common_tags = {
  Environment = "qa"
  Project     = "test"
  ManagedBy   = "Terraform"
  Owner       = "DevOps"
}
