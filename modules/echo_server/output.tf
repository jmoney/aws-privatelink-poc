output "instance_ip" {
    value = aws_instance.echo_server.private_ip
}

output "instance_id" {
    value = aws_instance.echo_server.id
}