terraform {
  backend "s3" {
    bucket         = "cv-website-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
