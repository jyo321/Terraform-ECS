# -------------------------
# Security Group for ALB
# -------------------------
resource "aws_security_group" "alb" {
  name        = var.alb_security_group_name
  description = var.alb_security_group_description
  vpc_id      = var.vpc_id

  # Allow HTTPS from anywhere
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  lifecycle {
    create_before_destroy = true
  }

  tags = var.common_tags
}

# -------------------------
# Security Group for ECS Service
# -------------------------
resource "aws_security_group" "ecs_service" {
  name        = var.ecs_security_group_name
  description = var.ecs_security_group_description
  vpc_id      = var.vpc_id

  # Allow traffic from ALB on container port
  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  lifecycle {
    create_before_destroy = true
  }

  tags = var.common_tags
}


# -------------------------
# Application Load Balancer
# -------------------------
resource "aws_lb" "main" {
  name                       = var.alb_name
  load_balancer_type         = var.load_balancer_type
  internal                   = var.alb_internal
  subnets                    = var.alb_subnet_ids
  security_groups            = [aws_security_group.alb.id]
  enable_deletion_protection = var.enable_deletion_protection

  tags = var.common_tags

}

# -------------------------
# Target Groups (One per Service)
# -------------------------
resource "aws_lb_target_group" "services" {
  for_each = var.services

  name        = "${var.alb_name}-${each.key}-tg"
  port        = var.target_group_port


  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    path    = lookup(each.value, "health_check_path", var.health_check_path)
    matcher = var.health_check_matcher
  }

  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.alb_name}-${each.key}-tg"
      Service = each.key
    }
  )
}

# -------------------------
# HTTPS Listener
# -------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}
# -------------------------
# Listener Rules - PATH-BASED ROUTING
# -------------------------
resource "aws_lb_listener_rule" "services" {
  for_each = var.services

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.alb_name}-${each.key}-rule"
      Service = each.key
    }
  )
}
# -------------------------
# ECS Cluster
# -------------------------
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  dynamic "setting" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      setting
    ]
  }

  tags = var.common_tags
}

# -------------------------
# IAM Role for ECS Task Execution
# -------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = var.ecs_task_assume_role_policy

  tags = var.common_tags
}

# -------------------------
# IAM Role Policy Attachments
# -------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policies" {
  for_each = toset(var.ecs_task_execution_policy_arns)

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

# -------------------------
# IAM Role for ECS Task (separate from execution role)
# -------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.ecs_task_execution_role_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policies" {
  for_each = toset(var.ecs_task_execution_policy_arns) # Using the same variable here

  role       = aws_iam_role.ecs_task_role.name
  policy_arn = each.value
}

locals {
  ecs_roles = {
    execution = aws_iam_role.ecs_task_execution_role.name
    task      = aws_iam_role.ecs_task_role.name
  }
}

resource "aws_iam_role_policy" "ecs_custom_passrole" {
  for_each = local.ecs_roles

  name = "allow-pass-task-role-${each.key}"
  role = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "iam:PassRole"
      Resource = aws_iam_role.ecs_task_role.arn
    }]
  })
}

# -------------------------
# ECR Repositories
# -------------------------
resource "aws_ecr_repository" "services" {
  for_each = var.services

  name = "${var.ecs_cluster_name}-${each.key}"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.ecs_cluster_name}-${each.key}"
      Service = each.key
    }
  )
}

# -------------------------
# ECS Task Definitions (One per Service)
# -------------------------
resource "aws_ecs_task_definition" "services" {
  for_each = var.services

  family                   = "${var.ecs_cluster_name}-${each.key}"
  network_mode             = var.task_network_mode
  requires_compatibilities = var.task_requires_compatibilities
  cpu                      = each.value.task_cpu
  memory                   = each.value.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = replace(
    file("${path.root}/${each.value.task_definition_file}"),
    "$${image_url}",
    "${aws_ecr_repository.services[each.key].repository_url}:latest"
  )

  dynamic "runtime_platform" {
    for_each = var.enable_runtime_platform ? [1] : []
    content {
      operating_system_family = var.runtime_platform_os
      cpu_architecture        = var.runtime_platform_cpu_arch
    }
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes = [
      container_definitions,
      cpu,
      memory
    ]
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.ecs_cluster_name}-${each.key}"
      Service = each.key
    }
  )
}

# -------------------------
# ECS Services (One per Service)
# -------------------------
resource "aws_ecs_service" "services" {
  for_each = var.services

  name                              = "${var.ecs_cluster_name}-${each.key}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.services[each.key].arn
  desired_count                     = each.value.desired_count
  launch_type                       = var.launch_type
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_execute_command            = var.enable_execute_command

  network_configuration {
    subnets          = var.ecs_service_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services[each.key].arn
    container_name   = each.value.container_name
    container_port   = var.container_port
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.enable_deployment_circuit_breaker ? [1] : []
    content {
      enable   = true
      rollback = var.deployment_circuit_breaker_rollback
    }
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "${var.ecs_cluster_name}-${each.key}"
      Service = each.key
    }
  )

  depends_on = [
    aws_lb_listener.http,
    aws_lb_target_group.services
  ]
}

# ----- ECS Service Auto Scaling Target -----
resource "aws_appautoscaling_target" "ecs" {
  for_each = var.services

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.services[each.key].name}"

  min_capacity = lookup(each.value, "min_capacity", 1)
  max_capacity = lookup(each.value, "max_capacity", 1)
}

# ----- ECS Service Auto Scaling Policy (CPU 70%) -----
resource "aws_appautoscaling_policy" "cpu_scaling" {
  for_each = var.services

  name               = "${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = lookup(each.value, "target_cpu_value", 70)
    scale_out_cooldown = 300
    scale_in_cooldown  = 0
  }
}