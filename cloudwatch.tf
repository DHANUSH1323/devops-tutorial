resource "aws_cloudwatch_log_group" "app" {
  name              = "/devops-app"
  retention_in_days = 7
}