output "consumer_ips" {
    value = aws_endpoint.private_link_consumer.network_interface_ids
}