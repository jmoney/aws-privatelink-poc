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

resource "aws_internet_gateway" "internet" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "internet" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet.id
    }
}

resource "aws_route_table_association" "internet" {
    count = length(aws_subnet.public_subnets)
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.internet.id
}

resource "aws_eip" "nat_eip" {
    count = length(aws_subnet.public_subnets)
}

resource "aws_nat_gateway" "nat" {
    count = length(aws_subnet.public_subnets)
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table" "private" {
    count = length(aws_subnet.subnets)
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
}

resource "aws_route_table_association" "private" {
    count = length(aws_subnet.subnets)
    subnet_id = aws_subnet.subnets[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}