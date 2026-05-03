variable "env" {}
variable "private_subnets" {}
variable "vpc_id" {}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.env}-fintech-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "fintech"
  username          = var.db_username
  password          = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
  multi_az             = true

  tags = {
    Name = "${var.env}-postgres"
  }
}

variable "db_username" {}
variable "db_password" { sensitive = true }

output "db_endpoint" { value = aws_db_instance.postgres.endpoint }