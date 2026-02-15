#!/bin/bash
# Installs kube-prometheus-stack (Prometheus + Grafana + AlertManager + MetricServer) 
# to the current Kubernetes context (works for both EKS and AKS).

set -e

NAMESPACE="monitoring"
RELEASE_NAME="taskflow-monitoring"

echo "=== Deploying Prometheus & Grafana to namespace: $NAMESPACE ==="

# 1. Add Prometheus Community Helm Repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. Create namespace if not exists
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 3. Deploy the Stack
# We disable persistent storage for this demo to save costs/complexity, 
# but in production, enable PVCs.
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --set grafana.adminPassword="admin" \
  --set prometheus.prometheusSpec.retention=1d \
  --set alertmanager.enabled=false \
  --wait

echo "\n=== Deployment Complete! ==="
echo "To access Grafana:"
echo "  kubectl port-forward svc/$RELEASE_NAME-grafana 3000:80 -n $NAMESPACE"
echo "  Open http://localhost:3000 (User: admin, Pass: admin)"
