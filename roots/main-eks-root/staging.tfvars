##### EKS Cluster #####

cluster_name    = "eks-cluster-staging"
cluster_version = "1.30"
cluster_cidr    = "172.20.0.0/16"
cluster_tag     = "eks-cluster-staging"

##### Trust policy #####

policy_effect      = "Allow"
policy_type        = "Service"
policy_identifiers = ["eks.amazonaws.com"]
policy_actions     = ["sts:AssumeRole"]

##### IAM Role #####

role_name = "eks-cluster-iam-role-staging"

##### Role policy attachment #####

attachment_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

##### EKS Cluster sg #####

eks_cluster_sg_name        = "EKS Cluster Security Group"
eks_cluster_sg_description = "Allow All inbound traffic from Self and all outbound traffic"
eks_cluster_sg_tags = {
  Name                             = "eks-cluster-sg-staging"
  "kubernetes.io/cluster/eks-cluster-staging" = "owned"
  "aws:eks:cluster-name"           = "eks-cluster-staging"
}
ingress_port_ipv4     = 443
ingress_protocol_ipv4 = "tcp"
egress_cidr_ipv4      = "0.0.0.0/0"
egress_protocol_ipv4  = "-1"
egress_cidr_ipv6      = "::/0"
egress_protocol_ipv6  = "-1"

##### EKS Workers IAM Role #####

eks_workers_iam_role_name             = "eks-workers-staging"
eks_workers_iam_role_action           = "sts:AssumeRole"
eks_workers_iam_role_effect           = "Allow"
eks_workers_iam_role_service          = "ec2.amazonaws.com"
eks_workers_policy_attachment_arn     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
eks_cni_policy_attachment_arn         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
eks_autoscaling_policy_attachment_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

##### EKS Worker nodes #####

node_group_name_01     = "eks-node-group-01-staging"
node_group_name_02     = "eks-node-group-02-staging"
scaling_config_desired = 2
scaling_config_max     = 3
scaling_config_min     = 1
node_group_ami_type    = "AL2_x86_64"
node_group_instance_types = ["t3.medium", "t3.small"]

##### VPC #####

vpc_cidr     = "10.88.0.0/16"
vpc_name     = "eks-project-vpc-staging"
igw_name     = "eks-project-internet-gateway-staging"
pub_rt_name  = "eks-project-public-route-table-staging"
priv_rt_name = "eks-project-private-route-table-staging"
public_subnet_object = {
  "pub_sub_1" = {
    cidr = "10.88.0.0/20",
    az   = "us-east-1a",
    name = "public-subnet-1-staging"
  },
  "pub_sub_2" = {
    cidr = "10.88.16.0/20",
    az   = "us-east-1b",
    name = "public-subnet-2-staging"
  }
}
private_subnet_object = {
  "priv_sub_1" = {
    cidr = "10.88.128.0/20",
    az   = "us-east-1a",
    name = "private-subnet-1-staging"
  },
  "priv_sub_2" = {
    cidr = "10.88.144.0/20",
    az   = "us-east-1b",
    name = "private-subnet-2-staging"
  }
}
eks_cluster_name = "eks-cluster-staging"
