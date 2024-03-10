output "public_lb_dns" {
    value = aws_lb.public_lb.dns_name
}

output "consumer_ips" {
    value = data.aws_network_interface.consumer_network_interface[*].private_ip
}

output "private_link_vpcs" {
    value = {
        "provider": module.provider_network.vpc_id,
        "consumer": module.consumer_network.vpc_id
    }
}

output "provider_service_name" {
    value = module.provider.service_name
}

output "echo_server_id" {
    value = module.echo_server.instance_id
}