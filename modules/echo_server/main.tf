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

resource "aws_iam_role" "echo_server" {
    name_prefix = "echo_server_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]

    # inline_policy {
    #     name = "echo-server-policy"
    #     policy = jsonencode({
    #         Version = "2012-10-17",
    #         Statement = [
    #             {
    #                 Action = "kms:GenerateDataKey",
    #                 Effect = "Allow",
    #                 Resource = "*"
    #             }
    #         ]
    #     })
    # }

}

resource "aws_iam_instance_profile" "echo_server" {
    name_prefix = "echo_server_profile"
    role = aws_iam_role.echo_server.name
}

resource "aws_instance" "echo_server" {
    ami = data.aws_ami.amazon_linux_2023.id
    instance_type = "t3.micro"
    subnet_id = var.subnet_id
    security_groups = [aws_security_group.echo_server.id]

    iam_instance_profile = aws_iam_instance_profile.echo_server.name

    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                sudo yum install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo docker run -d --network host --name echo-server ghcr.io/jmoney/echo-server:v0.5
                EOF
}

resource "aws_security_group" "echo_server" {
    vpc_id = var.vpc_id
    name_prefix = "echo-server-ingress"
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