module "t75-app" {
  source = "./resources"
  ACCOUNT_ID = var.ACCOUNT_ID
  RDS_DEFAULT_PASS = var.RDS_DEFAULT_PASS
  RDS_DEFAULT_USER = var.RDS_DEFAULT_USER
  REGION = var.REGION
}

provider "aws" {
  region = var.REGION
}
