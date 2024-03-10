terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.40.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"

    default_tags {
        tags = {
            Name = "private-link-poc"
        }
    }
}

locals {
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "provider_network" {
    source = "./modules/network_segment"
    cidr_block = "10.0.0.0/16"
    availability_zones = local.availability_zones
}

module "consumer_network" {
    source = "./modules/network_segment"
    cidr_block = "10.1.0.0/16"
    availability_zones = local.availability_zones
}

module "echo_server" {
    source = "./modules/echo_server"
    subnet_id = module.provider_network.subnet_ids["private"][element(local.availability_zones, 0)]
    vpc_id = module.provider_network.vpc_id
}

module "provider" {
    source = "./modules/provider"
    subnet_ids = [for az, subnet in module.provider_network.subnet_ids["private"] : subnet]
    instance_ip = module.echo_server.instance_ip
}

module "consumer" {
    source = "./modules/consumer"
    vpc_id = module.consumer_network.vpc_id
    service_name = module.provider.service_name
    subnet_ids = [for az, subnet in module.consumer_network.subnet_ids["private"] : subnet]   
}

#### Below is everything needed to access the consumer network via the public internet

resource "aws_security_group" "public_lb" {
    name = "public-lb"
    vpc_id = module.consumer_network.vpc_id
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "public_lb" {
    name = "public-lb"
    internal = false
    load_balancer_type = "application"
    subnets = [for az, subnet in module.consumer_network.subnet_ids["public"] : subnet]
    security_groups = [aws_security_group.public_lb.id]
    enable_deletion_protection = false
    enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "public_lb" {
    load_balancer_arn = aws_lb.public_lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.public_lb.arn
    }
}

resource "aws_lb_target_group" "public_lb" {
    name = "public-lb"
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = module.consumer_network.vpc_id

    health_check {
        path = "/http"
        protocol = "HTTP"
        port = "80"
        interval = 30
        timeout = 5
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
}

data "aws_network_interface" "consumer_network_interface" {
    count = length(local.availability_zones)
    id = module.consumer.consumer_network_interface_ids[count.index]
}

resource "aws_lb_target_group_attachment" "consumers" {
    count = length(data.aws_network_interface.consumer_network_interface)
    target_group_arn = aws_lb_target_group.public_lb.arn
    target_id = data.aws_network_interface.consumer_network_interface[count.index].private_ip
    port = 80
}

resource "aws_security_group_rule" "private_link_provider_ingress" {
    count = (var.open_provider_ingress ? 1 : length(data.aws_network_interface.consumer_network_interface))
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = module.provider.provider_security_group_id
    cidr_blocks = (var.open_provider_ingress ? ["10.0.0.0/8"] : [format("%s/32", data.aws_network_interface.consumer_network_interface[count.index].private_ip)])
}