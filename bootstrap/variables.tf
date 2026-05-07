variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "dhanush-tfstate-us-east-2"
}

variable "local_table_name" {
  description = "Dynamo db table name"
  type        = string
  default     = "terraform-locks"
}