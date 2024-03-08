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
}

module "provider_network" {
    source = "./modules/network_segment"
    cidr_block = "10.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "consumer_network" {
    source = "./modules/network_segment"
    cidr_block = "10.1.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "echo_server" {
    source = "./modules/echo_server"
    subnet_id = module.provider_network.subnet_ids["private"]["us-east-1a"]
    vpc_id = module.provider_network.vpc_id
}

module "provider" {
    source = "./modules/provider"
    # TODO - grab all private subnets from the provider network
    subnet_ids = [module.provider_network.subnet_ids["private"]["us-east-1a"], module.provider_network.subnet_ids["private"]["us-east-1b"]]
    instance_ip = module.echo_server.instance_ip
    cidr_block = var.provider_ingress_cidr_block
}

module "consumer" {
    source = "./modules/consumer"

    vpc_id = module.consumer_network.vpc_id
    service_name = module.provider.service_name

}

#### Below is everything needed to access the consumer network via the public internet

resource "aws_internet_gateway" "internet" {
    vpc_id = module.consumer_network.vpc_id
}

resource "aws_lb" "public_lb" {
    name = "public-lb"
    internal = false
    load_balancer_type = "application"
    # TODO - grab all public subnets from the consumer network
    subnets = [module.consumer_network.subnet_ids["public"]["us-east-1a"], module.consumer_network.subnet_ids["public"]["us-east-1b"]]
    enable_deletion_protection = false
    tags = {
        Name = "public-lb"
    }
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
    vpc_id = module.consumer_network.vpc_id

    health_check {
        path = "/health"
        protocol = "HTTP"
        port = "traffic-port"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "consumers" {
    # TODO - map this to the consumer network availability zones
    count = 3
    target_group_arn = aws_lb_target_group.public_lb.arn
    target_id = module.consumer.consumer_ips[count.index]
    port = 80
}