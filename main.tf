provider "aws" {
  region = "us-east-2"
}

locals {
  ecr_registry = "${aws_ecr_repository.app.registry_id}.dkr.ecr.${var.region}.amazonaws.com"
  image_full   = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2_app.name
  vpc_security_group_ids      = [aws_security_group.app.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io curl unzip
    systemctl start docker
    systemctl enable docker

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip

    aws ecr get-login-password --region ${var.region} \
      | docker login --username AWS --password-stdin ${local.ecr_registry}

    docker pull ${local.image_full}
    docker run -d --restart=always --name app \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.region} \
      --log-opt awslogs-group=${aws_cloudwatch_log_group.app.name} \
      --log-opt awslogs-stream=app \
      -p 8000:8000 ${local.image_full}
  EOF

  tags = {
    Name = var.instance_name
  }
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
