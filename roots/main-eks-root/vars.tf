##### EKS Cluster #####

variable "cluster_name" {
  type    = string
  default = "eks-cluster-dev"
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
  default = "eks-cluster-dev"
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
  default = "eks-cluster-iam-role-dev"
}

##### Role policy attachment #####
variable "attachment_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

##### EKS Cluster sg #####
variable "eks_cluster_sg_name" {
  type    = string
  default = "EKS Cluster Security Group"
}

variable "eks_cluster_sg_description" {
  type    = string
  default = "Allow All inbound traffic from Self and all outbound traffic"
}

variable "eks_cluster_sg_vpc_id" {
  type    = string
  default = ""
}

variable "eks_cluster_sg_tags" {
  type = map(string)
  default = {
    Name = "eks-cluster-sg-dev"
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
  default = "eks-workers-dev"
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
  default = "eks-node-group-01-dev"
}

variable "node_group_name_02" {
  type    = string
  default = "eks-node-group-02-dev"
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

### VPC variables ###

variable "vpc_cidr" {
  type    = string
  default = "10.88.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "eks-project-vpc"
}

variable "igw_name" {
  type    = string
  default = "eks-project-internet-gateway"
}

variable "pub_rt_name" {
  type    = string
  default = "eks-project-public-route-table"
}

variable "priv_rt_name" {
  type    = string
  default = "eks-project-private-route-table"
}

variable "public_subnet_object" {
  type = map(object({
    cidr = string,
    az   = string,
    name = string
  }))
  default = {
    "pub_sub_1" = {
      cidr = "10.88.0.0/20",
      az   = "us-east-1a",
      name = "public-subnet-1"
    },
    "pub_sub_2" = {
      cidr = "10.88.16.0/20",
      az   = "us-east-1b",
      name = "public-subnet-2"
    }
  }
}

variable "private_subnet_object" {
  type = map(object({
    cidr = string,
    az   = string,
    name = string
  }))
  default = {
    "priv_sub_1" = {
      cidr = "10.88.128.0/20"
      az   = "us-east-1a",
      name = "private-subnet-1"
    },
    "priv_sub_2" = {
      cidr = "10.88.144.0/20",
      az   = "us-east-1b",
      name = "private-subnet-2"
    }
  }
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-cluster-dev"
}
