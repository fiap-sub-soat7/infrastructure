resource "aws_ecr_repository" "t75-ecr_ms_vehicle" {
  name = "t75-ms-vehicle"
}

resource "aws_ecr_repository" "t75-ecr_ms_client" {
  name = "ms-client"
}
