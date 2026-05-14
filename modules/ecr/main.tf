resource "aws_ecr_repository" "app" {
  name                 = "devops-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}