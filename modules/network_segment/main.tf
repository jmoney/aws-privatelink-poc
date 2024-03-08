resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
}

resource "aws_subnet" "subnets" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
    availability_zone = var.availability_zones[count.index]
}

resource "aws_subnet" "public_subnets" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + length(var.availability_zones)) # start the public subnets after the private subnets
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true
}