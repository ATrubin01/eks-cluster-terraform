##### EKS Workers IAM Role #####

resource "aws_iam_role" "eks_workers" {
  name = var.eks_workers_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = var.eks_workers_iam_role_action
        Effect = var.eks_workers_iam_role_effect
        Principal = {
          Service = var.eks_workers_iam_role_service
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_workers" {
  role       = aws_iam_role.eks_workers.name
  policy_arn = var.eks_workers_policy_attachment_arn
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_workers.name
  policy_arn = var.eks_cni_policy_attachment_arn
}

resource "aws_iam_role_policy_attachment" "eks_autoscaling" {
  role       = aws_iam_role.eks_workers.name
  policy_arn = var.eks_autoscaling_policy_attachment_arn
}

##### EKS Worker Nodes #####

# Node Group 01 - t3.medium instances
resource "aws_eks_node_group" "node_group_01" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name_01
  node_role_arn   = aws_iam_role.eks_workers.arn
  subnet_ids      = var.node_group_private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  ami_type       = var.node_group_ami_type
  instance_types = ["t3.medium"]

  tags = {
    Name = "node-group-01"
  }
}

# Node Group 02 - t3.small instances with taints
resource "aws_eks_node_group" "node_group_02" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name_02
  node_role_arn   = aws_iam_role.eks_workers.arn
  subnet_ids      = var.node_group_private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  ami_type       = var.node_group_ami_type
  instance_types = ["t3.small"]

  taint {
    key    = "app"
    value  = "podinfo"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "node-group-02"
  }
}

output "eks_worker_role_arn" {
  value = aws_iam_role.eks_workers.arn
}
