terraform {
  backend "s3" {
    bucket = "t75-app-resources"  
    key = "terraform.tfstate"

    region = "us-east-1"
  }
}

# TODO: !important - update `.terraform.lock.hcl` after apply