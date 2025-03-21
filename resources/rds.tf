resource "aws_db_instance" "t74-inventory-db" {
  identifier        = "t75-inventory-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  db_subnet_group_name = aws_db_subnet_group.t75-db_subnets.name
  vpc_security_group_ids = [aws_security_group.t75-sg.id]
  username          = var.RDS_DEFAULT_USER
  password          = var.RDS_DEFAULT_PASS
  db_name           = "t75_inventory"
  publicly_accessible = true
  skip_final_snapshot  = true 
}

resource "aws_db_subnet_group" "t75-db_subnets" {
  name        = "t75-db-subnets"
  subnet_ids  = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]
}

resource "aws_db_instance" "t75-sonarcloud" {
  identifier      = "t75-sonarcloud"
  storage_type    = "gp2"
  engine          = "postgres"
  engine_version  = "15.10"
  instance_class  = "db.t4g.micro"
  db_name         = "sonarcloud"
  username        = "sonar_usr"
  password        = "z3XLYoLUbg9IYJ86RN7QjmZQFYCjQYaU"
  allocated_storage    = 20
  publicly_accessible  = true 
  db_subnet_group_name = aws_db_subnet_group.t75-db_subnets.name
  vpc_security_group_ids = [aws_security_group.t75-sg.id]

  backup_retention_period = 0
  multi_az = false
}
