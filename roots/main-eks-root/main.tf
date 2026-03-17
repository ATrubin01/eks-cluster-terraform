module "eks-module" {
  source = "../../eks-module"
  ##### EKS Cluster #####
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  cluster_subnet_ids = module.vpc.private_subnet_ids
  cluster_cidr       = var.cluster_cidr
  cluster_tag        = var.cluster_tag
  ##### Trust policy #####
  policy_effect      = var.policy_effect
  policy_type        = var.policy_type
  policy_identifiers = var.policy_identifiers
  policy_actions     = var.policy_actions
  ##### IAM Role #####
  role_name = var.role_name
  ##### Role policy attachment #####
  attachment_policy_arn = var.attachment_policy_arn
  ##### EKS Cluster sg #####
  eks_cluster_sg_name        = var.eks_cluster_sg_name
  eks_cluster_sg_description = var.eks_cluster_sg_description
  eks_cluster_sg_vpc_id      = module.vpc.vpc_id
  eks_cluster_sg_tags        = var.eks_cluster_sg_tags
  ingress_port_ipv4          = var.ingress_port_ipv4
  ingress_protocol_ipv4      = var.ingress_protocol_ipv4
  egress_cidr_ipv4           = var.egress_cidr_ipv4
  egress_protocol_ipv4       = var.egress_protocol_ipv4
  egress_cidr_ipv6           = var.egress_cidr_ipv6
  egress_protocol_ipv6       = var.egress_protocol_ipv6
  ##### EKS Workers IAM Role #####
  eks_workers_iam_role_name             = var.eks_workers_iam_role_name
  eks_workers_iam_role_action           = var.eks_workers_iam_role_action
  eks_workers_iam_role_effect           = var.eks_workers_iam_role_effect
  eks_workers_iam_role_service          = var.eks_workers_iam_role_service
  eks_workers_policy_attachment_arn     = var.eks_workers_policy_attachment_arn
  eks_cni_policy_attachment_arn         = var.eks_cni_policy_attachment_arn
  eks_autoscaling_policy_attachment_arn = var.eks_autoscaling_policy_attachment_arn
  ##### EKS Worker nodes #####
  node_group_name_01            = var.node_group_name_01
  node_group_name_02            = var.node_group_name_02
  node_group_private_subnet_ids = module.vpc.private_subnet_ids
  scaling_config_desired        = var.scaling_config_desired
  scaling_config_max            = var.scaling_config_max
  scaling_config_min            = var.scaling_config_min
  node_group_ami_type           = var.node_group_ami_type
  node_group_instance_types     = var.node_group_instance_types
}

module "vpc" {
  source                = "../../vpc"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  igw_name              = var.igw_name
  pub_rt_name           = var.pub_rt_name
  priv_rt_name          = var.priv_rt_name
  public_subnet_object  = var.public_subnet_object
  private_subnet_object = var.private_subnet_object
  eks_cluster_name      = var.eks_cluster_name
}
