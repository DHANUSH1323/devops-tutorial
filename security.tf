resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow HTTP traffic to the app"
}

resource "aws_security_group_rule" "app_ingress" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # anywhere
  security_group_id = aws_security_group.app.id
}


resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}
