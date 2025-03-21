#!/bin/bash

# Deploy Microservices Framework

set -e

# Variables
NAMESPACE="microservices"
CURRENT_DIR=$(pwd)
KUBE_DIR="$CURRENT_DIR/infrastructure/kubernetes"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "Kubernetes cluster is not accessible. Please check your kubeconfig."
    exit 1
fi

# Create namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl apply -f "$KUBE_DIR/base/namespace.yaml"
fi

# Apply base configuration
echo "Applying base Kubernetes configurations..."
kubectl apply -f "$KUBE_DIR/base"

# Apply environment-specific configurations (based on parameter)
ENV=${1:-dev}
if [[ "$ENV" == "prod" || "$ENV" == "staging" || "$ENV" == "dev" ]]; then
    echo "Applying $ENV environment configurations..."
    kubectl apply -f "$KUBE_DIR/overlays/$ENV"
else
    echo "Invalid environment specified. Using dev as default."
    kubectl apply -f "$KUBE_DIR/overlays/dev"
fi

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl -n $NAMESPACE rollout status deployment/api-gateway
kubectl -n $NAMESPACE rollout status deployment/auth-service
kubectl -n $NAMESPACE rollout status deployment/user-service
kubectl -n $NAMESPACE rollout status deployment/product-service

# Apply service mesh configurations
echo "Applying service mesh configurations..."
kubectl apply -f "$CURRENT_DIR/infrastructure/service-mesh/traffic-management.yaml"

# Display service endpoints
echo "Service endpoints:"
echo "API Gateway: $(kubectl -n $NAMESPACE get svc api-gateway -o jsonpath='{.spec.clusterIP}')"
echo "Auth Service: $(kubectl -n $NAMESPACE get svc auth-service -o jsonpath='{.spec.clusterIP}')"
echo "User Service: $(kubectl -n $NAMESPACE get svc user-service -o jsonpath='{.spec.clusterIP}')"
echo "Product Service: $(kubectl -n $NAMESPACE get svc product-service -o jsonpath='{.spec.clusterIP}')"

echo "Deployment completed successfully!" 