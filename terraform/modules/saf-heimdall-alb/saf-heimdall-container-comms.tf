
##
# Security group that enables communication betewwn
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
#
resource "aws_security_group" "SafHeimdallContainerCommsSG" {
  name        = "SafHeimdallContainerCommsSG-${var.deployment_id}"
  description = "Allow port 3000 communication with own SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SafHeimdallContainerCommsSG-${var.deployment_id}"
  }
}

##
# Ingress SG rule that allows port 3000 communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHeimdallContainerCommsIngressRule" {
  description = "Ingress SG rule that allows HTTPS communication with own SG"

  type      = "ingress"
  from_port = 3000
  to_port   = 3000
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHeimdallContainerCommsSG.id
  self              = true
}

##
# Egress SG rule that allows port 3000 communication with own SG
# 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
#
resource "aws_security_group_rule" "SafHeimdallContainerCommsEgressRule" {
  description = "Egress SG rule that allows HTTPS communication with own SG"

  type      = "egress"
  from_port = 3000
  to_port   = 3000
  protocol  = "tcp"

  security_group_id = aws_security_group.SafHeimdallContainerCommsSG.id
  self              = true
}
