output "subnet_cidr_blocks" {
    value = map("private", {
                    for subnet in aws_subnet.subnets : subnet.availability_zone => subnet.cidr_block
                },
                "public", {
                    for subnet in aws_subnet.public_subnet : public_subnet.availability_zone => public_subnet.cidr_block
                }
    )
}

output "subnet_ids" {
    value = map("private", {
                    for subnet in aws_subnet.subnets : subnet.availability_zone => subnet.id
                },
                "public", {
                    for subnet in aws_subnet.public_subnet : public_subnet.availability_zone => public_subnet.id
                }
    )
}