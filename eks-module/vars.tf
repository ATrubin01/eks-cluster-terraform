##### EKS Cluster #####

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "cluster_subnet_ids" {
  type    = list(string)
  default = []
}

variable "cluster_cidr" {
  type    = string
  default = "172.20.0.0/16"
}

variable "cluster_tag" {
  type    = string
  default = "eks-cluster"
}

##### Trust policy #####
variable "policy_effect" {
  type    = string
  default = "Allow"
}

variable "policy_type" {
  type    = string
  default = "Service"
}

variable "policy_identifiers" {
  type    = list(string)
  default = ["eks.amazonaws.com"]
}

variable "policy_actions" {
  type    = list(string)
  default = ["sts:AssumeRole"]
}

##### IAM Role #####
variable "role_name" {
  type    = string
  default = "eks-cluster-iam-role"
}

##### Role policy attachment #####
variable "attachment_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

##### EKS Cluster Security Group #####
variable "eks_cluster_sg_name" {
  type    = string
  default = "eks-cluster-sg"
}

variable "eks_cluster_sg_description" {
  type    = string
  default = "Allow all inbound traffic from within VPC and all outbound traffic"
}

variable "eks_cluster_sg_vpc_id" {
  type    = string
  default = ""
}

variable "eks_cluster_sg_tags" {
  type = map(string)
  default = {
    Name = "eks-cluster-sg"
  }
}

variable "ingress_port_ipv4" {
  type    = number
  default = 443
}

variable "ingress_protocol_ipv4" {
  type    = string
  default = "tcp"
}

variable "egress_cidr_ipv4" {
  type    = string
  default = "0.0.0.0/0"
}

variable "egress_protocol_ipv4" {
  type    = string
  default = "-1"
}

variable "egress_cidr_ipv6" {
  type    = string
  default = "::/0"
}

variable "egress_protocol_ipv6" {
  type    = string
  default = "-1"
}

########## Worker Node Group ###########

##### EKS Workers IAM Role #####

variable "eks_workers_iam_role_name" {
  type    = string
  default = "eks-workers"
}

variable "eks_workers_iam_role_action" {
  type    = string
  default = "sts:AssumeRole"
}

variable "eks_workers_iam_role_effect" {
  type    = string
  default = "Allow"
}

variable "eks_workers_iam_role_service" {
  type    = string
  default = "ec2.amazonaws.com"
}

variable "eks_workers_policy_attachment_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

variable "eks_cni_policy_attachment_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

variable "eks_autoscaling_policy_attachment_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##### EKS Worker nodes #####
variable "node_group_name_01" {
  type    = string
  default = "eks-node-group-01"
}

variable "node_group_name_02" {
  type    = string
  default = "eks-node-group-02"
}

variable "node_group_private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "scaling_config_desired" {
  type    = number
  default = 2
}

variable "scaling_config_max" {
  type    = number
  default = 3
}

variable "scaling_config_min" {
  type    = number
  default = 1
}

variable "node_group_ami_type" {
  type    = string
  default = "AL2_x86_64"
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium", "t3.small"]
}
