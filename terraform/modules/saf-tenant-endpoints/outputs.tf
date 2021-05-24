
output "s3VpcEndpoint" {
  value = aws_vpc_endpoint.vpc.s3VpcEndpoint.dns_name
}

output "s3VpcEndpointPrefixListCidr" {
  value = aws_prefix_list.s3VpcEndpointPrefixList.cidr_blocks[0]
}

output "ConfigToHdfSsmVpcEndpoint" {
  value = aws_vpc_endpoint.vpc.ConfigToHdfSsmVpcEndpoint.dns_name
}

output "ConfigToHdfConfigVpcEndpoint" {
  value = aws_vpc_endpoint.vpc.ConfigToHdfConfigVpcEndpoint.dns_name
}

output "CloudWatchVpcEndpoint" {
  value = aws_vpc_endpoint.vpc.CloudWatchVpcEndpoint.dns_name
}

output "EcrDkrVpcEndpoint" {
  value = aws_vpc_endpoint.vpc.EcrDkrVpcEndpoint.dns_name
}

output "EcrApiVpcEndpoint" {
  value = aws_vpc_endpoint.vpc.EcrApiVpcEndpoint.dns_name
}
