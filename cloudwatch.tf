resource "aws_cloudwatch_log_group" "app" {
  name              = "/devops-app"
  retention_in_days = 7
}

resource "aws_sns_topic" "alerts" {
  name = "devops-app-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}