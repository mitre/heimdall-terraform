output "public_alb_target_group_id" {
  value = aws_alb_target_group.public-heimdal-alb-targetgroup.id
}

output "private_alb_target_group_id" {
  value = aws_alb_target_group.private-heimdal-alb-targetgroup.id
}

output "public_alb_address" {
  value = aws_alb.heimdall-alb-public.dns_name
}

output "private_alb_address" {
  value = aws_alb.heimdall-alb-private.dns_name
}

output "SafHeimdallContainerCommsSG" {
  value = aws_security_group.SafHeimdallContainerCommsSG.id
}
