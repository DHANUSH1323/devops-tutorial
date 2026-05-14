variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}

variable "region" {
  description = "AWS region the EC2 lives in (used for ECR login + log streams)."
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy."
  type        = string
  default     = "latest"
}

variable "ecr_registry_id" {
  description = "ECR registry ID (AWS account ID)."
  type        = string
}

variable "ecr_repository_url" {
  description = "Full ECR repository URL (without tag)."
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group to send container logs to."
  type        = string
}
