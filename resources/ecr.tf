resource "aws_ecr_repository" "t75-ecr_ms_order" {
  name = "ms-vehicle"
}

resource "aws_ecr_repository" "t75-ecr_ms_payment" {
  name = "ms-payment"
}

resource "aws_ecr_repository" "t75-ecr_ms_inventory" {
  name = "ms-inventory"
}

resource "aws_ecr_repository" "t75-ecr_ms_identity" {
  name = "ms-identity"
}
