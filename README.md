# EKS Cluster Terraform

Production-ready Amazon EKS cluster provisioned with Terraform, including a containerized web app with CI/CD, Golden AMI, and Prometheus/Grafana monitoring.

## Architecture

```
eks-cluster-terraform/
├── vpc/                          # VPC module (subnets, routing, NAT gateway)
├── eks-module/                   # EKS module (cluster, node groups, IAM, OIDC, autoscaler)
├── roots/
│   └── main-eks-root/            # Root module — wires vpc + eks together
│       └── kubernetes_resources/ # Cluster autoscaler, gp3 storage class manifests
├── web-app/                      # Node.js web app
│   ├── Dockerfile
│   ├── server.js
│   ├── package.json
│   └── k8s/
│       ├── deployment.yaml       # 2 replicas spread across nodes
│       ├── service.yaml
│       ├── ingress.yaml          # Nginx ingress
│       └── podinfo/              # stefanprodan/podinfo on Node Group 02
│           ├── podinfo-deployment.yaml
│           ├── podinfo-service.yaml
│           └── podinfo-hpa.yaml  # HPA to trigger cluster autoscaler
├── golden-ami/
│   ├── packer.json               # Builds Ubuntu 22.04 + Nginx AMI
│   └── main.tf                   # Provisions EC2 from Golden AMI
├── prometheus/                   # Prometheus + Grafana manifests
└── .github/workflows/
    ├── terraform-deploy.yaml     # CI/CD for infrastructure
    └── app-deploy.yaml           # CI/CD for web app (build, push ECR, deploy EKS)
```

## What's Included

**Infrastructure (Terraform)**
- VPC with public/private subnets across 2 AZs (CIDR: 10.88.0.0/16)
- NAT Gateway for private subnet egress
- EKS cluster (v1.30) with managed node groups on private subnets
- Add-Ons: VPC CNI, EBS CSI Driver
- Node Group 01: `t3.medium` (min 2, max 3) — general workloads
- Node Group 02: `t3.small` with `NoSchedule` taint — isolated workloads (podinfo)
- IAM roles with IRSA (IAM Roles for Service Accounts) via OIDC
- Cluster Autoscaler with dedicated IAM role
- gp3 StorageClass set as default (replaces gp2, reclaimPolicy: Retain)

**Web Application**
- Simple Node.js app displaying "Hello, my name is Alon!"
- Containerized with Docker, image pushed to Amazon ECR
- Deployed with 2 replicas spread across different worker nodes via `topologySpreadConstraints`
- Exposed via Nginx Ingress Controller at `web-app.alontrubin.com`

**podinfo**
- Deploys `stefanprodan/podinfo` on Node Group 02 (with taint toleration)
- HPA configured to scale up to 10 replicas at 50% CPU — triggers Cluster Autoscaler

**CI/CD (GitHub Actions)**
- `terraform-deploy.yaml` — runs on push to `main`/`staging`/`dev`, plans and applies Terraform
- `app-deploy.yaml` — builds Docker image, pushes to ECR, deploys to EKS on push to `main`
- Uses OIDC (no static AWS credentials stored in GitHub)
- Multi-environment support via branch-based tfvars (dev/staging/production)

**Golden AMI**
- Packer builds Ubuntu 22.04 LTS with Nginx pre-installed
- Terraform provisions an EC2 instance using the Golden AMI

**Monitoring**
- Prometheus for metrics collection
- Grafana for visualization
- Ingress configured for both Prometheus and Grafana dashboards

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Helm
- Packer (for Golden AMI)
- S3 bucket for Terraform remote state
- DynamoDB table for state locking (`terraform-state-lock`)

## Setup

### 1. Build the Golden AMI
```bash
cd golden-ami
packer build packer.json
```

### 2. Provision EKS Infrastructure
```bash
cd roots/main-eks-root
cp dev.tfvars.example dev.tfvars
# Fill in your values in dev.tfvars

terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="key=terraform/eks/dev.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-state-lock" \
  -backend-config="encrypt=true"

terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### 3. Configure kubectl
```bash
aws eks update-kubeconfig --name eks-cluster-dev --region us-east-1
```

### 3a. Grant your local IAM user access to the cluster

The cluster is created by the GitHub Actions IAM role, so by default your local IAM user has no access. Run these to fix it:

```bash
# Enable API auth mode
aws eks update-cluster-config \
  --name eks-cluster-dev \
  --access-config authenticationMode=API_AND_CONFIG_MAP \
  --region us-east-1

# Wait ~30 seconds for it to apply, then add your IAM user as cluster admin
aws eks create-access-entry \
  --cluster-name eks-cluster-dev \
  --principal-arn $(aws sts get-caller-identity --query Arn --output text) \
  --region us-east-1

aws eks associate-access-policy \
  --cluster-name eks-cluster-dev \
  --principal-arn $(aws sts get-caller-identity --query Arn --output text) \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster \
  --region us-east-1
```

Verify it works:
```bash
kubectl get nodes
```

### 4. Apply Kubernetes Resources
```bash
# Storage class and cluster autoscaler
kubectl apply -f roots/main-eks-root/kubernetes_resources/gp3-storage-class.yaml
kubectl apply -f roots/main-eks-root/kubernetes_resources/cluster-autoscaler.yaml

# Install Nginx Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Deploy web app (after CI/CD pushes image to ECR)
kubectl apply -f web-app/k8s/

# Deploy podinfo on Node Group 02
kubectl apply -f web-app/k8s/podinfo/
```

### 5. Install Prometheus + Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install stable prometheus-community/kube-prometheus-stack \
  --namespace prometheus --create-namespace
kubectl apply -f prometheus/
```

### 6. Provision EC2 from Golden AMI
```bash
cd golden-ami
terraform init
terraform apply -var="ami_id=YOUR_GOLDEN_AMI_ID"
```

## CI/CD GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `IAM_ROLE` | ARN of the GitHub Actions IAM role (OIDC) |
| `TF_STATE_BUCKET` | S3 bucket name for Terraform state |
| `EKS_CLUSTER_NAME` | EKS cluster name |

## Trigger Cluster Autoscaler

Scale podinfo replicas to trigger autoscaler to provision new nodes:
```bash
kubectl scale deployment podinfo --replicas=10
```

Watch new nodes come up:
```bash
kubectl get nodes -w
```

Scale back down:
```bash
kubectl scale deployment podinfo --replicas=2
```
