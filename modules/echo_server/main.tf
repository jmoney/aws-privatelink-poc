data "aws_ami" "amazon_linux_2023" {
    most_recent = true

    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["al2023-ami-2023.3.20240131.0-kernel-6.1-x86_64"] 
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_vpc" "vpc" {
    id = var.vpc_id
}

resource "aws_instance" "echo_server" {
    ami = data.aws_ami.amazon_linux_2023.id
    instance_type = "t2.micro"
    subnet_id = var.subnet_id
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo docker run -d -p 9001:9001 --name echo-server ghcr.io/jmoney/echo-server:v0.5
                EOF
}

resource "aws_security_group" "echo_server" {
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