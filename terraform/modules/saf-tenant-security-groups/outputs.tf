
output "SafHTTPCommsSG_id" {
  value = aws_security_group.SafHTTPCommsSG.id
}

output "SafEgressOnlySG_id" {
  value = aws_security_group.SafEgressOnlySG.id
}