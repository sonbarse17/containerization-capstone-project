# TaskFlow - Cloud-Native Platform Engineering Capstone

![TaskFlow Architecture](https://via.placeholder.com/800x400?text=TaskFlow+Architecture+Diagram)
*(Placeholder: Generate diagram using Mermaid below)*

## Overview
**TaskFlow** is a comprehensive, production-grade cloud-native application platform, designed to demonstrate mastery in Platform Engineering. 
It features a microservices-based Kanban application deployed across **AWS (EKS)** and **Azure (AKS)** using Infrastructure as Code (Terraform), Kubernetes (Helm), and CI/CD automation.

### **Core Features** (Compliance Checklist)
- ✅ **Containerization**: Multi-stage Docker builds, Distroless images, Vulnerability Scanning (Trivy).
- ✅ **Infrastructure as Code**: Modular Terraform for VPC/VNet, EKS/AKS, ECR/ACR, S3/Storage.
- ✅ **Environments**: Dev, Stage, Prod (paramterized via `.tfvars`).
- ✅ **Orchestration**: Self-healing Deployments, StatefulSets (Postgres), Jobs/CronJobs, DaemonSets.
- ✅ **Advanced Deployment**: Canary releases, HPA Autoscaling, Ingress Routing (ALB).
- ✅ **Security**: IRSA (AWS), Managed Identity (Azure), Network Policies, RBAC, Secret Management.
- ✅ **Automation**: GitHub Actions & Azure Pipelines for CI/CD with automated rollback.
- ✅ **Observability**: Prometheus & Grafana stack (monitoring namespace).

---

## **Architecture Diagram**

```mermaid
graph TD
    subgraph "Cloud Provider (AWS/Azure)"
        subgraph "Infrastructure (Terraform)"
            VPC[VPC / VNet]
            EKS[Kubernetes Cluster (EKS/AKS)]
            S3[Object Storage (S3/Blob)]
            KV[Secret Manager (Vault)]
        end

        subgraph "Kubernetes (Helm)"
            Ingress[Ingress Controller (ALB/Nginx)]
            
            subgraph "TaskFlow Namespace"
                Frontend[Frontend (Deploy)]
                Backend[Backend (Deploy + HPA)]
                DB[(Postgres StatefulSet)]
                
                Running[CronJob: Cleanup]
            end
            
            subgraph "Monitoring Namespace"
                Prom[Prometheus]
                Graf[Grafana]
            end
        end
    end

    User --> Ingress
    Ingress --> Frontend
    Ingress --> Backend
    Frontend --> Backend
    Backend --> DB
    Backend -- Read Secrets --> KV
    Backend -- Store Files --> S3
    Prom -- Scrape --> Backend
```

---

## **Repository Structure**

```
.
├── backend/                 # Python Flask Microservice (Distroless Dockerfile)
├── frontend/                # React/Nginx Microservice (Unprivileged Dockerfile)
├── infrastructure/          # Terraform IaC
│   ├── modules/             # Reusable Modules (vpc, eks, aks, s3...)
│   └── environments/        # environment configs (aws/main.tf, azure/main.tf)
├── k8s/                     # Kubernetes Manifests
│   └── taskflow-chart/      # Helm Chart (Templates + Values for envs)
├── monitoring/              # Observability Stack (Prometheus/Grafana)
├── scripts/                 # Utility scripts (scan_images.sh)
├── .github/workflows/       # GitHub Actions CI/CD
└── azure-pipelines.yml      # Azure DevOps Pipeline
```

---

## **Deployment Guide**

### **Prerequisites**
- Terraform >= 1.0
- Docker & Docker Compose
- kubectl & helm
- AWS CLI or Azure CLI configured

### **1. Infrastructure Deployment (AWS Example)**
```bash
cd infrastructure/environments/aws
terraform init
terraform apply -var-file="dev.tfvars"
# Output will provide the kubeconfig command
```

### 2. Build & Scan Images
```bash
# Build locally
docker-compose build

# Scan manually (requires Trivy installed)
trivy image taskflow-dev-backend:latest
```

### **3. Application Deployment (Kubernetes)**
```bash
# Deploy to Dev environment
helm upgrade --install taskflow ./k8s/taskflow-chart \
  --namespace dev --create-namespace

# Deploy to Prod with overrides
helm upgrade --install taskflow ./k8s/taskflow-chart \
  --namespace prod --create-namespace \
  -f k8s/taskflow-chart/values-prod.yaml
```

### **4. Observability Setup**
```bash
./monitoring/deploy.sh
# Follow instructions to access Grafana dashboards
```

---

## **Design Decisions & Trade-offs**

### **1. Container Security**
- **Decision**: Use `gcr.io/distroless/python3` for backend.
- **Why**: Drastically reduces attack surface (no shell, no package manager in prod).
- **Trade-off**: Harder to debug (can't `exec` into pod easily), so we rely on logs and DaemonSet monitoring.

### **2. Secret Management**
- **Decision**: Use cloud-native identity (IRSA for AWS, Managed Identity for Azure).
- **Why**: Avoids long-lived credentials. Pods authenticate directly with the cloud provider to access S3/KeyVault.

### **3. Scaling Strategy**
- **Decision**: HPA based on CPU utilization (default 50%).
- **Why**: Stateless backend is CPU-bound.
- **Decision**: StatefulSet for DB.
- **Why**: Ensures stable network identity and orderly scaling/termination.

### **4. CI/CD Strategy**
- **Decision**: Atomic Helm upgrades.
- **Why**: Ensures if a deployment fails, it automatically rolls back to the previous stable state, minimizing downtime.
