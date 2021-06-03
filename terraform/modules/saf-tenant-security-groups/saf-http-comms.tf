
##
# Security group that enables communication betewwn
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#
resource "aws_security_group" "SafHTTPCommsSG" {
  name        = "SafHTTPCommsSG"
  description = "Allow port 80 and 443 communication with own SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SafHTTPCommsSG",#-${var.deployment_id}",
    Owner   = basename(data.aws_caller_identity.current.arn),
    #Project = local.name,
  }
}

##
# Ingress SG rule that allows HTTPS communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHTTPSCommsIngressRule" {
  description = "Ingress SG rule that allows HTTPS communication with own SG"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHTTPCommsSG.id
  self              = true
}

##
# Egress SG rule that allows HTTPS communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHTTPSCommsEgressRule" {
  description = "Egress SG rule that allows HTTPS communication with own SG"

  type      = "egress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHTTPCommsSG.id
  self              = true
}

##
# Ingress SG rule that allows HTTP communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHTTPCommsIngressRule" {
  description = "Ingress SG rule that allows HTTP communication with own SG"

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHTTPCommsSG.id
  self              = true
}

##
# Egress SG rule that allows HTTP communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHTTPCommsEgressRule" {
  description = "Egress SG rule that allows HTTP communication with own SG"

  type      = "egress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHTTPCommsSG.id
  self              = true
}
