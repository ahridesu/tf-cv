terraform {
  backend "s3" {
    bucket         = "infra-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
