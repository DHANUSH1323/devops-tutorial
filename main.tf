provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}

module "ecr" {
  source = "./modules/ecr"
}

module "observability" {
  source = "./modules/observability"
}

module "compute" {
  source = "./modules/compute"

  region             = var.region
  image_tag          = var.image_tag
  ecr_registry_id    = module.ecr.registry_id
  ecr_repository_url = module.ecr.repository_url
  log_group_name     = module.observability.log_group_name
}

# State-move blocks — tell Terraform these resources were relocated, not destroyed/recreated.

moved {
  from = aws_ecr_repository.app
  to   = module.ecr.aws_ecr_repository.app
}

moved {
  from = aws_cloudwatch_log_group.app
  to   = module.observability.aws_cloudwatch_log_group.app
}

moved {
  from = aws_sns_topic.alerts
  to   = module.observability.aws_sns_topic.alerts
}

moved {
  from = aws_sns_topic_subscription.email
  to   = module.observability.aws_sns_topic_subscription.email
}

moved {
  from = aws_iam_role.ec2_app
  to   = module.compute.aws_iam_role.ec2_app
}

moved {
  from = aws_iam_role_policy_attachment.ecr_read
  to   = module.compute.aws_iam_role_policy_attachment.ecr_read
}

moved {
  from = aws_iam_role_policy_attachment.cw_agent
  to   = module.compute.aws_iam_role_policy_attachment.cw_agent
}

moved {
  from = aws_iam_instance_profile.ec2_app
  to   = module.compute.aws_iam_instance_profile.ec2_app
}

moved {
  from = aws_security_group.app
  to   = module.compute.aws_security_group.app
}

moved {
  from = aws_security_group_rule.app_ingress
  to   = module.compute.aws_security_group_rule.app_ingress
}

moved {
  from = aws_security_group_rule.app_egress
  to   = module.compute.aws_security_group_rule.app_egress
}

moved {
  from = aws_instance.app_server
  to   = module.compute.aws_instance.app_server
}

moved {
  from = data.aws_ami.ubuntu
  to   = module.compute.data.aws_ami.ubuntu
}
