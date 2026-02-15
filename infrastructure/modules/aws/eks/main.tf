locals {
  cluster_name = "${var.project_name}-${var.environment}-cluster"
}

# --- IAM Role for EKS Cluster ---
resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# --- IAM Role for EKS Node Group ---
resource "aws_iam_role" "node_group" {
  name = "${local.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# --- EKS Cluster ---
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

# --- Security Group for Worker Nodes ---
resource "aws_security_group" "node_group" {
  name_prefix = "${local.cluster_name}-node-sg"
  vpc_id      = var.vpc_id
  description = "Security group for all nodes in the cluster"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                        = "${local.cluster_name}-node-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node_group.id
  source_security_group_id = aws_security_group.node_group.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes to communicate with the cluster control plane
resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_group.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

# --- Launch Template for Node Group ---
resource "aws_launch_template" "node_group" {
  name = "${local.cluster_name}-launch-template"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.cluster_name}-node"
    }
  }
}

# --- EKS Node Group ---
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  launch_template {
    id      = aws_launch_template.node_group.id
    version = "$Latest"
  }

  # Instance types must be specified in Launch Template if used, NOT here. 
  # Wait, standard practice allows overrides but cleaner to put in LT.
  # However, for simplicity with variables, let's keep managed overrides here?
  # Actually, EKS API says if launch template is specified, instance types should be there or here.
  # To keep using the variable easily without complex LT logic, let's keep it here.
  instance_types = var.node_group_instance_types

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# --- OIDC Provider (Optional but recommended for IRSA) ---
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
