output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = module.compute.instance_hostname
}

output "public_ip" {
  description = "Public IPv4 of the EC2 instance."
  value       = module.compute.public_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for pushing app images"
  value       = module.ecr.repository_url
}
