output "public_lb_dns" {
    description = "value of the public load balancer's DNS name"
    value = aws_lb.public_lb.dns_name
}

output "consumer_ips" {
    description = "IP addresses of the consumer network interfaces"
    value = data.aws_network_interface.consumer_network_interface[*].private_ip
}

output "private_link_vpcs" {
    description = "VPC IDs of the provider and consumer networks"
    value = {
        "provider": module.provider_network.vpc_id,
        "consumer": module.consumer_network.vpc_id
    }
}

output "provider_service_name" {
    description = "value of the provider service name"
    value = module.provider.service_name
}

output "echo_server_id" {
    description = "value of the echo server's instance ID"
    value = module.echo_server.instance_id
}