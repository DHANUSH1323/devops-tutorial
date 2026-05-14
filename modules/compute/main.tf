data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

locals {
  ecr_registry = "${var.ecr_registry_id}.dkr.ecr.${var.region}.amazonaws.com"
  image_full   = "${var.ecr_repository_url}:${var.image_tag}"
}

resource "aws_iam_role" "ec2_app" {
  name = "ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_app" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_app.name
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow HTTP traffic to the app"
}

resource "aws_security_group_rule" "app_ingress" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
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
      --log-opt awslogs-group=${var.log_group_name} \
      --log-opt awslogs-stream=app \
      -p 8000:8000 ${local.image_full}
  EOF

  tags = {
    Name = var.instance_name
  }
}
