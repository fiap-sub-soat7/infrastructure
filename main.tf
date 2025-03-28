module "t75-app" {
  source = "./resources"
  ACCOUNT_ID = var.AWS_ACCOUNT_ID
  REGION = var.REGION
}

provider "aws" {
  region = var.REGION
}
