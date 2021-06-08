
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

# Password variable for task definition
locals {
  DATABASE_URL = join("", ["postgres://${var.rds_user_name}:", urlencode(var.rds_password), "@${var.rds_endpoint}/${var.rds_db_name}"])
}

##
# Egress SG rule that allows communication with S3 Gateway Endpoint
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "S3GatewayEndpointEgressRule" {
  description = "Egress SG rule that allows communication with S3 Gateway Endpoint"

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = var.vpcEndpoint_security_group
  cidr_blocks       = [var.s3VpcEndpointPrefixListCidr]
}

#Create CloudWatch Logging Gorup
resource "aws_cloudwatch_log_group" "heimdall_cwatch" {
  name = "${var.proj_name}_heimdall-terraform-${var.deployment_id}"

  tags = {
    Name        = "${var.proj_name}-heimdall-cw-loggroup-${var.deployment_id}"
    Owner       = var.your_name
    Project     = var.your_name
    Application = "heimdall"
  }
}

#Create ECS Cluster
resource "aws_ecs_cluster" "heimdall_cluster" {
  name = "${var.proj_name}_heimdall-${var.deployment_id}"

  tags = {
    Name    = "${var.proj_name}-heimdall-ECS-cluster-${var.deployment_id}"
    Owner   = var.your_name
    Project = var.your_name
  }
}
data "aws_ecs_cluster" "heimdall_cluster" {
  cluster_name = "${var.proj_name}_heimdall-${var.deployment_id}"

  depends_on = [
    aws_ecs_cluster.heimdall_cluster,
  ]
}

resource "aws_ecs_task_definition" "heimdall_task_definition" {
  family                   = "${var.proj_name}_heimdall-${var.deployment_id}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  task_role_arn            = aws_iam_role.ECS_execution_agent_1.arn
  execution_role_arn       = aws_iam_role.ECS_execution_agent_1.arn

  tags = {
    Name    = "${var.proj_name}-heimdall-task-definition-${var.deployment_id}"
    Owner   = var.your_name
    Project = var.your_name
  }
  container_definitions = <<DEFINITION
[
  {
    "cpu": 1024,
    "image": "${var.heimdall_image}",
    "memory": 2048,
    "name": "${var.proj_name}-heimdall-container",
    "healthCheck": {
            "Command": [
                "CMD-SHELL",
                "wget -q --spider http://localhost/ || exit 1"
            ],
            "Interval": 300,
            "Timeout": 60
        },
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000
      }
    ],
	"logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group" : "${aws_cloudwatch_log_group.heimdall_cwatch.name}",
        "awslogs-region": "${var.aws_region}",
		"awslogs-stream-prefix": "${var.proj_name}-heimdall-container-logs"
      }
    },
	"environment": [
            {
                "Name": "DATABASE_URL",
                "Value": "${local.DATABASE_URL}"
            },
            {
                "Name": "RAILS_SERVE_STATIC_FILES",
                "Value": "${var.RAILS_SERVE_STATIC_FILES}"
            },
            {
                "Name": "RAILS_ENV",
                "Value": "${var.RAILS_ENV}"
            },
            {
                "Name": "HEIMDALL_RELATIVE_URL_ROOT",
                "Value": "${var.HEIMDALL_RELATIVE_URL_ROOT}"
            },
            {
                "Name": "DISABLE_SPRING",
                "Value": "${var.DISABLE_SPRING}"
            },
            {
                "Name": "RAILS_LOG_TO_STDOUT",
                "Value": "${var.RAILS_LOG_TO_STDOUT}"
            },
            {
                "Name": "DATABASE_PASSWORD",
                "Value": "${var.rds_password}"
            },
            {
                "Name": "NODE_ENV",
                "Value": "production"
            },
            {
                "Name": "JWT_SECRET",
                "Value": "eba1d0bbfdce4b099e7d09c27a369c66640ad2876ff84774aa0bd1eb3808dc3f38cc8a790ff72fb1a91a5ba1818c231b30837e8e8a953424494bd9c562039b0f"
            },
            {
                "Name": "JWT_EXPIRE_TIME",
                "Value": "1d"
            }
        ]
    }
]
DEFINITION
}

##
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
#
resource "aws_ecs_service" "main" {
  name            = "${var.proj_name}-heimdall-service-${var.deployment_id}"
  cluster         = aws_ecs_cluster.heimdall_cluster.id
  task_definition = aws_ecs_task_definition.heimdall_task_definition.arn
  desired_count   = "2"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.ecs_security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  # Public ALB
  load_balancer {
    target_group_arn = var.public_alb_target_group_id
    container_name   = "${var.proj_name}-heimdall-container"
    container_port   = "3000"
  }

  # Private ALB
  load_balancer {
    target_group_arn = var.private_alb_target_group_id
    container_name   = "${var.proj_name}-heimdall-container"
    container_port   = "3000"
  }

  #depends_on = [
  #  aws_alb_listener.front_end_tls,
  #]

  # Add this when the new ARN and resource IDs are used on your AWS accounts
  #  tags = {
  #    Owner   = "${var.your_name}"
  #    Project = "${var.proj_name}"
  #  }
}

# ROLES #################################

resource "aws_iam_role" "ECS_execution_agent_1" {
  name = "${var.proj_name}_ECS_execution_agent_1-${var.deployment_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  # Allow READ access to Heimdall ECR
  inline_policy {
    name = "AwsEcrRepoReadAccess-${var.deployment_id}"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer"
          ]
          Effect   = "Allow"
          Resource = var.heimdall_ecr_arn
        }
      ]
    })
  }

  # ecr:GetAuthorizationToken requires wildcard access
  inline_policy {
    name = "AwsEcrAuthorizationTokenAccess-${var.deployment_id}"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:GetAuthorizationToken"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    Name    = "${var.proj_name}-heimdall-ECS-role-${var.deployment_id}"
    Owner   = var.your_name
    Project = var.your_name
  }
}

# ATTACH ECS ROLE ########################################

resource "aws_iam_role_policy_attachment" "ECSTaskExec-attach" {
  role       = aws_iam_role.ECS_execution_agent_1.name
  policy_arn = var.AmazonECSTaskExecutionRolePolicy_arn
}
resource "aws_iam_role_policy_attachment" "RDSFullAccess-attach" {
  role       = aws_iam_role.ECS_execution_agent_1.name
  policy_arn = var.AmazonRDSDataFullAccess_arn
}

# FOR DEV
# A security group with accessible via the web
# resource "aws_security_group" "heimdall_ecs_sg" {
#   name        = "heimdall_ecs_sg"
#   description = "heimdall_ecs_sg, includes both gatekeepers and vpns, based on f8e0"
#   vpc_id      = "${var.vpc_id}"

#   tags = {
#     Name   = "${var.proj_name}-heimdall_ecs_sg"
#     Owner   = "${var.your_name}"
#     Project = "${var.proj_name}"
#   }

#   # INGRESSES ####
#   ### This needs to be updated after dev is completed ##
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 1024
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # EGRESSES ####
#   # egress {
#   #   from_port   = 0
#   #   to_port     = 0
#   #   protocol    = "-1"
#   #   cidr_blocks = ["127.0.0.1/32"]
#   # }
# }