output "repository_url" {
  description = "URL of the ECR repository for pushing app images"
  value       = aws_ecr_repository.app.repository_url
}

output "registry_id" {
  description = "AWS account ID hosting the registry"
  value       = aws_ecr_repository.app.registry_id
}