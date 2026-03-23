terraform {
  backend "s3" {
    bucket               = "demo-terraform-qa-state"
    key                  = "terraform.tfstate"
    region               = "us-east-2"
    encrypt              = true
    workspace_key_prefix = "workspaces"
  }
}