data "aws_subnet" "subnet" {
    id = var.subnet_ids[0]
}

resource "aws_security_group" "private_link_provider" {
    vpc_id = data.aws_subnet.subnet.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [data.aws_subnet.subnet.cidr_block]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.cidr_block]
    }
}

resource "aws_lb" "private_link_provider" {
    name = "private-link-provider"
    internal = true
    load_balancer_type = "network"
    subnets = var.subnet_ids
    enable_deletion_protection = false
}

resource "aws_lb_target_group" "private_link_provider" {
  name     = "private-link-provider"
  port     = 80
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = data.aws_subnet.subnet.vpc_id

  health_check {
    protocol = "TCP"
    port     = "9001"
    interval = 30
    timeout  = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "private_link_provider" {
  target_group_arn = aws_lb_target_group.private_link_provider.arn
  target_id        = var.instance_ip
  port             = 9001
}

resource "aws_lb_listener" "private_link_provider" {
  load_balancer_arn = aws_lb.private_link_provider.arn
  protocol          = "TCP"
  port              = "80"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_link_provider.arn
  }
}

resource "aws_vpc_endpoint_service" "private_link_provider" {
    network_load_balancer_arns = [aws_lb.private_link_provider.arn]
    acceptance_required = false
}