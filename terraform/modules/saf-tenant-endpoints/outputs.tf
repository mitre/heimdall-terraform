
output "s3VpcEndpointPrefixListCidr" {
  # value = aws_prefix_list.s3VpcEndpointPrefixList.cidr_blocks[0]
  value = aws_vpc_endpoint.s3VpcEndpoint.cidr_blocks[0]
}

output "SsmVpcEndpoint" {
  value = aws_vpc_endpoint.SsmVpcEndpoint.dns_entry[0].dns_name
}

output "ConfigVpcEndpoint" {
  value = aws_vpc_endpoint.ConfigVpcEndpoint.dns_entry[0].dns_name
}

output "CloudWatchVpcEndpoint" {
  value = aws_vpc_endpoint.CloudWatchVpcEndpoint.dns_entry[0].dns_name
}

output "EcrDkrVpcEndpoint" {
  value = aws_vpc_endpoint.EcrDkrVpcEndpoint.dns_entry[0].dns_name
}

output "EcrApiVpcEndpoint" {
  value = aws_vpc_endpoint.EcrApiVpcEndpoint.dns_entry[0].dns_name
}
