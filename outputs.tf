output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for pushing app images"
  value       = aws_ecr_repository.app.repository_url
}
