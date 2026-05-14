output "log_group_name" {
  description = "Name of the CloudWatch log group for the app"
  value       = aws_cloudwatch_log_group.app.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alarms"
  value       = aws_sns_topic.alerts.arn
}
