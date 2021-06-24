
##
# Create private ALB
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
#
resource "aws_alb" "heimdall-alb-private" {
  name            = "heimdall-alb-private-${var.deployment_id}"
  subnets         = var.private_subnet_ids
  security_groups = concat([aws_security_group.SafHeimdallContainerCommsSG.id], var.addl_alb_sg_ids)
  internal        = true
  
  access_logs {
    bucket  = aws_s3_bucket.elb_logging_bucket.bucket
    prefix  = "heimdall-private-lb"
    enabled = true
  }

  tags = {
    Name    = "heimdall-alb-private-${var.deployment_id}"
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = var.proj_name
  }
}

##
# Target group for the private ALB to direct to.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# 
resource "aws_alb_target_group" "private-heimdal-alb-targetgroup" {
  name        = "private-heimdal-alb-tg-${var.deployment_id}"
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
    Name    = "private-heimdal-alb-tg-${var.deployment_id}"
    Owner   = basename(data.aws_caller_identity.current.arn)
    Project = var.proj_name
  }
}

##
# Redirect all traffic from the ALB to the target group
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
#
resource "aws_alb_listener" "private_front_end_tls" {
  load_balancer_arn = aws_alb.heimdall-alb-private.id
  port              = "80"
  protocol          = "HTTP"

  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.private-heimdal-alb-targetgroup.id
    type             = "forward"
  }
}

#resource "aws_lb_listener" "front_end_redir" {
#  load_balancer_arn = aws_alb.heimdall-alb-private.id
#  port              = "80"
#  protocol          = "HTTP"

#  default_action {
#    type = "redirect"

#    redirect {
#      port        = "443"
#      protocol    = "HTTPS"
#      status_code = "HTTP_301"
#    }
#  }
#}
