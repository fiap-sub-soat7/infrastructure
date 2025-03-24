terraform {
  backend "s3" {
    bucket = "vehicle-app-resources"  
    key = "terraform.tfstate"

    region = "us-east-1"
  }
}

# TODO: !important - update `.terraform.lock.hcl` after apply