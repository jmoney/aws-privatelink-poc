output "public_lb_dns" {
    value = aws_lb.public_lb.dns_name
}