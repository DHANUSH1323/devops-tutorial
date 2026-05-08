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

variable "bucket_name" {
  description = "s3 Bucket name"
  type        = string
  default     = "dhanush-tfstate-us-east-2"
}

variable "region" {
  description = "region name"
  type        = string
  default     = "us-east-2"
}

variable "image_tag" {
  description = "Docker image tag to deploy (e.g. commit SHA from CI). Defaults to 'latest'."
  type        = string
  default     = "latest"
}