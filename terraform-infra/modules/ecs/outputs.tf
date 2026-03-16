# -------------------------
# ALB Outputs
# -------------------------
output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

# -------------------------
# Security Group Outputs
# -------------------------
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS service security group ID"
  value       = aws_security_group.ecs_service.id
}

# -------------------------
# ECS Cluster Outputs
# -------------------------
output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

# -------------------------
# IAM Role Outputs
# -------------------------
output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  value       = aws_iam_role.ecs_task_execution_role.name
}

# -------------------------
# Target Group Outputs
# -------------------------
output "target_group_arns" {
  description = "Map of target group ARNs"
  value       = { for k, v in aws_lb_target_group.services : k => v.arn }
}

output "target_group_names" {
  description = "Map of target group names"
  value       = { for k, v in aws_lb_target_group.services : k => v.name }
}

# -------------------------
# Task Definition Outputs
# -------------------------
output "task_definition_arns" {
  description = "Map of task definition ARNs"
  value       = { for k, v in aws_ecs_task_definition.services : k => v.arn }
}

output "task_definition_families" {
  description = "Map of task definition families"
  value       = { for k, v in aws_ecs_task_definition.services : k => v.family }
}

output "task_definition_revisions" {
  description = "Map of task definition revisions"
  value       = { for k, v in aws_ecs_task_definition.services : k => v.revision }
}

# -------------------------
# ECS Service Outputs
# -------------------------
output "service_names" {
  description = "Map of ECS service names"
  value       = { for k, v in aws_ecs_service.services : k => v.name }
}

output "service_ids" {
  description = "Map of ECS service IDs"
  value       = { for k, v in aws_ecs_service.services : k => v.id }
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.http.arn
}

 