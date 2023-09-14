terraform {
  backend "s3" {
    bucket               = "movies-terraform-backend"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "ec2"
    dynamodb_table       = "movies-db-backend"
    encrypt              = true
  }
}
