terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Bucket and Key passed via CLI (-backend-config)
    # bucket       = "taskflow-terraform-state"
    # key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/aws/vpc"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  cluster_name = "${var.project_name}-${var.environment}-cluster"
}

module "eks" {
  source = "../../modules/aws/eks"

  environment  = var.environment
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  node_group_instance_types = var.instance_types
  cluster_version           = var.cluster_version
}

# repositories
module "ecr_frontend" {
  source = "../../modules/aws/ecr"

  environment     = var.environment
  project_name    = var.project_name
  repository_name = "frontend"
}

module "ecr_backend" {
  source = "../../modules/aws/ecr"

  environment     = var.environment
  project_name    = var.project_name
  repository_name = "backend"
}

# outputs
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = "${var.project_name}-${var.environment}-cluster"
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${var.project_name}-${var.environment}-cluster"
}

output "ecr_frontend_url" {
  value = module.ecr_frontend.repository_url
}

output "ecr_backend_url" {
  value = module.ecr_backend.repository_url
}

# s3 bucket for data
module "data_bucket" {
  source = "../../modules/aws/s3"

  environment  = var.environment
  project_name = var.project_name
  bucket_name  = "app-data"
}

output "data_bucket_name" {
  value = module.data_bucket.bucket_name
}

# irsa setup for pods accessing s3
data "aws_iam_policy_document" "app_s3_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${element(split("oidc-provider/", module.eks.oidc_provider_arn), 1)}:sub"
      values   = ["system:serviceaccount:${var.environment}:taskflow-app"]
    }
  }
}

resource "aws_iam_role" "app_s3_role" {
  name               = "${var.project_name}-${var.environment}-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.app_s3_trust.json
}

resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.project_name}-${var.environment}-s3-access-policy"
  description = "Policy for app pods to access common data bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          module.data_bucket.bucket_arn,
          "${module.data_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_attach" {
  role       = aws_iam_role.app_s3_role.name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

output "irsa_role_arn" {
  value = aws_iam_role.app_s3_role.arn
}

# monitoring
module "cloudwatch" {
  source = "../../modules/aws/cloudwatch"

  environment  = var.environment
  project_name = var.project_name
}

output "cloudwatch_log_group" {
  value = module.cloudwatch.log_group_name
}
