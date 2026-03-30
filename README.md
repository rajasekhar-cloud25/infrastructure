# ecommerce-k8s-infrastructure

# Infrastructure — Ecommerce K8s Demo

Complete AWS infrastructure using Terraform modules.
Redis and PostgreSQL run as pods inside the cluster — no extra AWS costs.

## Architecture

```
AWS us-east-1 (Primary)
├── VPC — 3 public + 3 private subnets across 3 AZs
├── EKS Cluster
│   ├── On-demand node group (prod workloads)
│   ├── Spot node group (dev workloads — 70% cheaper)
│   └── Namespaces:
│       ├── boutique-dev    (dev environment)
│       ├── boutique-prod   (production)
│       ├── monitoring      (Grafana, Prometheus, Loki)
│       └── argocd          (GitOps)
├── ECR — Container registry for all 13 services
├── S3 — App assets + DB backups
└── IAM — IRSA roles for ALB, Autoscaler, EBS CSI

Inside EKS (Helm — no extra AWS cost):
├── Redis (pod) — cart data
└── PostgreSQL (pod) — order history

AWS us-west-2 (DR)
├── VPC
├── EKS Cluster (warm standby — scaled down)
└── Route 53 — auto-failover from primary
```

## Module Structure

```
terraform/
├── bootstrap.sh                    ← Run once first
├── modules/
│   ├── vpc/                        ← VPC, subnets, NAT
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/                        ← EKS + node groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                        ← Container registry
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                        ← IRSA roles
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── s3/                         ← Storage buckets
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── primary/                    ← us-east-1
    │   ├── versions.tf             ← providers + backend
    │   ├── variables.tf
    │   ├── main.tf                 ← calls all modules
    │   ├── outputs.tf
    └── dr/                         ← us-west-2
        └── main.tf
```

## Prerequisites

```bash
# Install required tools
brew install terraform kubectl helm awscli

# Verify versions
terraform version   # >= 1.5.0
kubectl version
helm version
aws --version
```

## Step 1 — Configure AWS CLI

```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output (json)

# Verify
aws sts get-caller-identity
```

## Step 2 — Bootstrap Terraform State (Run Once)

```bash
cd terraform
chmod +x bootstrap.sh
./bootstrap.sh

# Copy the bucket name from output
# Update versions.tf:
# bucket = "ecommerce-demo-terraform-state-YOURACCOUNTID"
```

## Step 3 — Deploy Primary Infrastructure

```bash
cd terraform/environments/primary

# Initialize — downloads providers and modules
terraform init

# Preview what will be created
terraform plan -out=tfplan

# Apply — takes ~15-20 minutes
terraform apply tfplan
```

## Step 4 — Configure kubectl

```bash
# Get command from terraform output
terraform output kubeconfig_command

# Run it — example:
aws eks update-kubeconfig \
  --name ecommerce-demo-primary \
  --region us-east-1

# Verify
kubectl get nodes
kubectl get namespaces
```

## Step 5 — Verify Redis and PostgreSQL

```bash
# Check Redis in dev
kubectl get pods -n boutique-dev | grep redis

# Check PostgreSQL in dev
kubectl get pods -n boutique-dev | grep postgresql

# Check Redis in prod
kubectl get pods -n boutique-prod | grep redis

# Check PostgreSQL in prod
kubectl get pods -n boutique-prod | grep postgresql

# Test PostgreSQL connection
kubectl exec -n boutique-dev \
  $(kubectl get pod -n boutique-dev -l app.kubernetes.io/name=postgresql -o name | head -1) \
  -- psql -U ecommerceuser -d ecommerce -c "\dt"
# Should show orders and order_items tables after orderservice starts
```

## Step 6 — Deploy DR Infrastructure (Optional)

```bash
cd terraform/environments/dr

# Update main.tf with your hosted zone ID and ALB DNS names
# then:
terraform init
terraform plan
terraform apply
```

## What Gets Deployed

| Resource | Count | Notes |
|---------|-------|-------|
| VPC | 1 | 3 AZs |
| Public subnets | 3 | For ALB |
| Private subnets | 3 | For EKS nodes |
| NAT Gateways | 3 | One per AZ for HA |
| EKS Cluster | 1 | v1.29 |
| On-demand nodes | 3 | t3.medium |
| Spot nodes | 2 | t3.medium/large |
| ECR repositories | 13 | One per service |
| Redis (dev pod) | 1 | Standalone |
| Redis (prod pod) | 1 | With replica |
| PostgreSQL (dev pod) | 1 | Single instance |
| PostgreSQL (prod pod) | 1 | With read replica |
| S3 buckets | 2 | Assets + backups |
| IAM roles | 3 | ALB, Autoscaler, EBS CSI |

## Estimated Cost

| Resource | Monthly |
|---------|---------|
| EKS cluster | ~$73 |
| 3x t3.medium on-demand | ~$90 |
| 2x t3.medium spot | ~$25 |
| 3x NAT Gateway | ~$100 |
| ECR storage | ~$5 |
| S3 + misc | ~$5 |
| **Total** | **~$298/month** |

### Cost Saving Tips
```bash
# Scale down nodes when not working
aws eks update-nodegroup-config \
  --cluster-name ecommerce-demo-primary \
  --nodegroup-name ecommerce-demo-primary-on-demand \
  --scaling-config minSize=0,maxSize=6,desiredSize=0 \
  --region us-east-1

# Scale back up when needed
aws eks update-nodegroup-config \
  --cluster-name ecommerce-demo-primary \
  --nodegroup-name ecommerce-demo-primary-on-demand \
  --scaling-config minSize=2,maxSize=6,desiredSize=3 \
  --region us-east-1
```

## Outputs Reference

| Output | Description |
|--------|-------------|
| `eks_cluster_name` | EKS cluster name |
| `eks_cluster_endpoint` | API server endpoint |
| `ecr_repository_urls` | All ECR URLs |
| `kubeconfig_command` | kubectl config command |
| `redis_dev_host` | Redis host for dev |
| `redis_prod_host` | Redis host for prod |
| `postgresql_dev_host` | PostgreSQL host for dev |
| `postgresql_prod_host` | PostgreSQL host for prod |
| `pg_dev_password_ssm` | SSM path for dev DB password |
| `pg_prod_password_ssm` | SSM path for prod DB password |

## Get PostgreSQL Password

```bash
# Dev password
aws ssm get-parameter \
  --name "/ecommerce-demo/dev/postgresql/password" \
  --with-decryption \
  --query Parameter.Value \
  --output text

# Prod password
aws ssm get-parameter \
  --name "/ecommerce-demo/prod/postgresql/password" \
  --with-decryption \
  --query Parameter.Value \
  --output text
```