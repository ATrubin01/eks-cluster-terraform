resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = var.cluster_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_cidr
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_AmazonEKSClusterPolicy
  ]

  tags = {
    Name = var.cluster_tag
  }
}

# Trust policy for the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = var.policy_effect

    principals {
      type        = var.policy_type
      identifiers = var.policy_identifiers
    }

    actions = var.policy_actions
  }
}

# Create IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSClusterPolicy" {
  policy_arn = var.attachment_policy_arn
  role       = aws_iam_role.eks_cluster_role.name
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = var.eks_cluster_sg_name
  description = var.eks_cluster_sg_description
  vpc_id      = var.eks_cluster_sg_vpc_id

  tags = var.eks_cluster_sg_tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  from_port                    = var.ingress_port_ipv4
  ip_protocol                  = var.ingress_protocol_ipv4
  to_port                      = var.ingress_port_ipv4

  lifecycle {
    ignore_changes = [
      from_port,
      to_port,
      ip_protocol,
      referenced_security_group_id,
    ]
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = var.egress_cidr_ipv4
  ip_protocol       = var.egress_protocol_ipv4
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv6         = var.egress_cidr_ipv6
  ip_protocol       = var.egress_protocol_ipv6
}

# Outputs
output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

# IAM Role for EKS Add-Ons
resource "aws_iam_role" "eks_addon_role" {
  name = "${var.cluster_name}-addon-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.cluster_name}-addon-role"
  }
}

# Attach policies to the role for the EBS CSI Add-On
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_addon_role.name
}

# EBS CSI Add-On
resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.eks_addon_role.arn

  timeouts {
    create = "40m"
    update = "40m"
    delete = "40m"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role.eks_addon_role,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.cluster
  ]
}
