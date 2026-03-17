# EKS Cluster Terraform

Production-ready Amazon EKS cluster provisioned with Terraform. Designed for multi-environment deployments with a modular structure.

## Architecture

```
eks-cluster-terraform/
├── vpc/                        # VPC module (subnets, routing, NAT gateway)
├── eks-module/                 # EKS module (cluster, node groups, IAM, OIDC, autoscaler)
└── roots/
    └── main-eks-root/          # Root module — wires vpc + eks together
        └── kubernetes_resources/  # Manifests for autoscaler, storage class
```

## What's Included

**Infrastructure (Terraform)**
- VPC with public/private subnets across 2 AZs
- NAT Gateway for private subnet egress
- EKS cluster (v1.30) with managed node groups
- Node Group 01: `t3.medium` (min 2, max 3)
- Node Group 02: `t3.small` with `NoSchedule` taint for isolated workloads
- EKS Add-Ons: VPC CNI, EBS CSI Driver
- IAM roles with IRSA (IAM Roles for Service Accounts) via OIDC
- Cluster Autoscaler with dedicated IAM role

**Kubernetes Manifests**
- Cluster Autoscaler deployment with RBAC
- gp3 StorageClass set as default (replaces gp2)

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- S3 bucket for Terraform remote state

## Usage

```bash
cd roots/main-eks-root

# Copy and fill in your values
cp dev.tfvars.example dev.tfvars

# Initialize with S3 backend
terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="key=eks/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan and apply
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

## After Apply

**Configure kubectl:**
```bash
aws eks update-kubeconfig --name eks-cluster-dev --region us-east-1
```

**Apply Kubernetes manifests:**
```bash
# Update YOUR_AWS_ACCOUNT_ID and YOUR_CLUSTER_NAME in cluster-autoscaler.yaml first
kubectl apply -f kubernetes_resources/gp3-storage-class.yaml
kubectl apply -f kubernetes_resources/cluster-autoscaler.yaml
```

## Tech Stack

- AWS EKS, EC2, VPC, IAM
- Terraform
- Kubernetes
- Helm (Prometheus/Grafana monitoring)
