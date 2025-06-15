terraform {
  backend "s3" {
    bucket = "sh-terraform-state-bucket"
    key    = "env/terraform.tfstate"
    region = "eu-central-1"
  }
}
