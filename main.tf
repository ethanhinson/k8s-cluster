
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    profile = var.profile_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "eks-cluster"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.64.0/19", "10.0.96.0/19", "10.0.128.0/19"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "env" = "dev"
  }
}


resource "aws_iam_role" "eks-iam-role" {
    name = "${var.cluster_name}-eks-iam-role"
    path = "/"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
            "Service": "eks.amazonaws.com"
        },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role    = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role    = aws_iam_role.eks-iam-role.name
}

resource "aws_eks_cluster" "cluster" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks-iam-role.arn

    vpc_config {
        subnet_ids = flatten([module.vpc.private_subnets, module.vpc.public_subnets])
    }

    depends_on = [
        aws_iam_role.eks-iam-role,
    ]
}

resource "aws_iam_role" "workernodes" {
    name = "eks-node-group"

    assume_role_policy = jsonencode({
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
        Version = "2012-10-17"
    })
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role    = aws_iam_role.workernodes.name
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
    policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
    role    = aws_iam_role.workernodes.name
 }
 
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role    = aws_iam_role.workernodes.name
 }

resource "aws_eks_node_group" "worker-node-group" {
    cluster_name  = aws_eks_cluster.cluster.name
    node_group_name = "${var.cluster_name}-workernodes"
    node_role_arn  = aws_iam_role.workernodes.arn
    subnet_ids   = flatten([module.vpc.private_subnets, module.vpc.public_subnets])
    instance_types = [var.instance_types]

    scaling_config {
        desired_size = 1
        max_size     = 3
        min_size     = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    ]
 }