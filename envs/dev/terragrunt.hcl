include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../"   # points at your existing root Terraform code
}

inputs = {
  region    = "us-east-2"
  image_tag = "latest"
}
