output "subnet_cidr_blocks" {
    value = {
                "private": {
                    for subnet in aws_subnet.subnets : subnet.availability_zone => subnet.cidr_block
                },
                "public": {
                    for subnet in aws_subnet.public_subnets : subnet.availability_zone => subnet.cidr_block
                }
        }
}

output "subnet_ids" {
    value = {
                "private": {
                    for subnet in aws_subnet.subnets : subnet.availability_zone => subnet.id
                },
                "public": {
                    for subnet in aws_subnet.public_subnets : subnet.availability_zone => subnet.id
                }
        }
}

output "vpc_id" {
    value = aws_vpc.vpc.id
}