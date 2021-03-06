
##
# Create public ALB
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
#
resource "aws_alb" "heimdall-alb-public" {
  name            = "heimdall-alb-frontend-${var.deployment_id}"
  subnets         = var.public_subnet_ids
  security_groups = concat([aws_security_group.SafHeimdallContainerCommsSG.id, aws_security_group.SafHeimdallAlbSG.id], var.addl_alb_sg_ids)
  internal = var.heimdall_alb_frontend_private
  
  access_logs {
    bucket  = aws_s3_bucket.elb_logging_bucket.bucket
    prefix  = "heimdall-frontend-lb"
    enabled = true
  }

  tags = {
    Name    = "heimdall-alb-frontend-${var.deployment_id}"
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = var.proj_name
  }
}

##
# Target group for the public ALB to direct to.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# 
resource "aws_alb_target_group" "public-heimdal-alb-targetgroup" {
  name        = "frontend-heimdal-alb-tg-${var.deployment_id}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # This health check is based on the start up and response time of Heimdall
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 60
    interval            = 300
    path                = "/login"
    port                = 3000
    matcher             = "200,304"
  }

  tags = {
    Name    = "frontend-heimdal-alb-tg-${var.deployment_id}"
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = var.proj_name
  }
}

##
# Redirect all traffic from the ALB to the target group
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
#
resource "aws_alb_listener" "public_front_end_tls" {
  load_balancer_arn = aws_alb.heimdall-alb-public.id
  port              = "80"
  protocol          = "HTTP"

  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.public-heimdal-alb-targetgroup.id
    type             = "forward"
  }
}

##
# A security group accessible via the web
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#
resource "aws_security_group" "SafHeimdallAlbSG" {
  name        = "SafHeimdallAlbSG-${var.deployment_id}"
  description = "SAF Heimdall ALB SG, allows ingress of HTTP and HTTPS"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.proj_name}-SafHeimdallAlbSG-${var.deployment_id}"
    #Owner   = basename(data.aws_caller_identity.current.arn)
    Project = var.proj_name
  }

  # INGRESSES ####
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
