terraform {
  backend "s3" {
    bucket               = "demo1-terraform-dev-state"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    encrypt              = true
    workspace_key_prefix = "workspaces"
  }
}