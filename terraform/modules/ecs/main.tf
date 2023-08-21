data "aws_iam_policy" "policy-gerenciada-1" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "main" {
  name = var.iam_role_ecs

  policy = jsonencode(
      {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ecr:GetAuthorizationToken",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:BatchGetImage",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:*"
              ],
              "Resource": "*"
          }
      ]
  }
  )
}
# Create an IAM role
resource "aws_iam_role" "ecs-task-role" {
  name = var.iam_role_ecs

  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "policy_ecs_attachment-1" {
  name       = "Policy Attachement policy ecs"
  policy_arn = aws_iam_policy.main.arn
  roles      = [aws_iam_role.ecs-task-role.name]
}

resource "aws_kms_key" "this" {
  description             = "log container keys"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.project_name
}


resource "aws_ecs_cluster" "this" {
  name = var.cluster-ecs-name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.this.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.this.name
      }
    }
  }

}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

data "aws_caller_identity" "current" {}


resource "aws_ecr_repository" "this" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.task_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "container-${var.project_name}-${var.environment}",
      "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "memory": 2048,
      "cpu": 1024,
      "logConfiguration": {
        "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.project_name}-${var.environment}",
            "awslogs-region": "${var.region}",
            "awslogs-create-group": "true", 
            "awslogs-stream-prefix": "ecs"
          }
        },
      "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "2048"
  cpu                      = "1024"
  execution_role_arn       = aws_iam_role.ecs-task-role.arn
}

resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = 0
  

  dynamic "load_balancer" {
    
    for_each = length(keys(var.load_balancer_1)) == 0 ? [] : [var.load_balancer_1]
    
    content {
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
      container_name   = "container-${var.project_name}-${var.environment}"
      container_port   = 80
    }
  }

    dynamic "load_balancer" {
    
    for_each = length(keys(var.load_balancer_2)) == 0 ? [] : [var.load_balancer_2]
    
    content {
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
      container_name   = "container-${var.project_name}-${var.environment}"
      container_port   = 80
    }
  }
  
  network_configuration {
    security_groups  = var.sg
    subnets          = var.sub-public
    assign_public_ip = true
  }
}