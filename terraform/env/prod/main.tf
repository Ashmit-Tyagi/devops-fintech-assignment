provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "fintech-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

module "vpc" {
  source = "../../modules/vpc"
  region = "us-east-1"
  env    = "prod"
}

module "eks" {
  source          = "../../modules/eks"
  env             = "prod"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "db" {
  source          = "../../modules/db"
  env             = "prod"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_username     = var.db_username
  db_password     = var.db_password
}

variable "db_username" {}
variable "db_password" { sensitive = true }