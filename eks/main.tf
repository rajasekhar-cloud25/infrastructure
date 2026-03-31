terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_security_group" "demo-sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,  {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  count             = length(var.workstation_cidr) > 0 ? 1 : 0
  cidr_blocks       = [var.workstation_cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_additional" {
  count = length(var.cluster_api_allowed_cidrs) > 0 ? 1 : 0

  cidr_blocks       = var.cluster_api_allowed_cidrs
  description       = "Allow additional CIDRs to access cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-sg.id
  to_port           = 443
  type              = "ingress"
}


# ─────────────────────────────────────────────
# EKS Node Security Group
# ─────────────────────────────────────────────
resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name                                        = "${var.cluster_name}-node-sg"
    "kubernetes.io/cluster/${var.cluster_name}"   = "owned"
  })
}

# Node-to-node communication
resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  type                     = "ingress"
}

# Control plane to nodes (kubelet, pods)
resource "aws_security_group_rule" "node_ingress_cluster" {
  description              = "Allow control plane to communicate with worker nodes"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.demo-sg.id
  type                     = "ingress"
}

# Control plane to nodes (HTTPS for metrics-server, logs)
resource "aws_security_group_rule" "node_ingress_cluster_https" {
  description              = "Allow control plane to communicate with nodes (HTTPS)"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.demo-sg.id
  type                     = "ingress"
}

# Nodes to control plane
resource "aws_security_group_rule" "cluster_ingress_node" {
  description              = "Allow worker nodes to communicate with control plane"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo-sg.id
  source_security_group_id = aws_security_group.node.id
  type                     = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    security_group_ids = [aws_security_group.demo-sg.id]
    subnet_ids         = var.private_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  depends_on = [var.cluster_policy_attachments]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node"
  })
}


resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [var.node_policy_attachments]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node"
  })
}



# GitHub Actions role — cluster admin
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.demo.name
  principal_arn = var.github_actions_role_arn
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.demo]
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = aws_eks_cluster.demo.name
  principal_arn = var.github_actions_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_actions]
}

# Your IAM user — cluster admin
resource "aws_eks_access_entry" "admin_user" {
  cluster_name  = aws_eks_cluster.demo.name
  principal_arn = var.admin_iam_user_arn
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.demo]
}

resource "aws_eks_access_policy_association" "admin_user" {
  cluster_name  = aws_eks_cluster.demo.name
  principal_arn = var.admin_iam_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_user]
}