data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_vpc_endpoint" "private_link_consumer" {
  vpc_id = var.vpc_id
  service_name = var.service_name
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.private_link_consumer.id]
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "private_link_consumer" {
    vpc_id = var.vpc_id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}