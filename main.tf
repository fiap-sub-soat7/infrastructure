module "t75-app" {
  source = "./resources"
  ACCOUNT_ID = var.ACCOUNT_ID
  REGION = var.REGION
}

provider "aws" {
  region = var.REGION
}
