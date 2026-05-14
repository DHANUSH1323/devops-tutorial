output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}

output "public_ip" {
  description = "Public IPv4 of the EC2 instance."
  value       = aws_instance.app_server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.app_server.id
}
