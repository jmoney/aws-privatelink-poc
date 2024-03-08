output "consumer_ips" {
    value = tolist(aws_vpc_endpoint.private_link_consumer.network_interface_ids)
}