variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-2"
}

variable "image_tag" {
  description = "Docker image tag to deploy (e.g. build number from Jenkins). Defaults to 'latest'."
  type        = string
  default     = "latest"
}
