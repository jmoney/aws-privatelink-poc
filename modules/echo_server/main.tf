data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"] # Pattern may need adjustment for Amazon Linux 2023
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # Ensure the AMI is owned by Amazon. You may need to adjust the owner ID for Amazon Linux 2023
  owners = ["amazon"] 
}

data "aws_vpc" "vpc" {
    id = var.vpc_id
}

resource "aws_instance" "echo_server" {
    ami = data.aws_ami.amazon_linux_2023.id
    instance_type = "t2.micro"
    subnet_id = var.subnet_id
    tags = {
        Name = "echo-server"
    }
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