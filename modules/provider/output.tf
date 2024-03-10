output "service_name" {
    value = aws_vpc_endpoint_service.private_link_provider.service_name
}

output "provider_security_group_id" {
    value = aws_security_group.private_link_provider.id
}