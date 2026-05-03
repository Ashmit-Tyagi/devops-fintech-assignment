variable "env" {}
variable "vpc_id" {}
variable "private_subnets" {}

resource "aws_eks_cluster" "main" {
  name     = "${var.env}-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.private_subnets
  }

  tags = {
    Name = "${var.env}-eks-cluster"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "${var.env}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-node-group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

output "cluster_name" { value = aws_eks_cluster.main.name }