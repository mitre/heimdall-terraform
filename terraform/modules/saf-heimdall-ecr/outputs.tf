
output "heimdall_image" {
  value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/mitre/heimdall2:release-latest"
}

output "heimdall_ecr_arn" {
  value = aws_ecr_repository.mitre_heimdall2.arn
}
