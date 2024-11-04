#!/bin/bash

# Variables
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
GITHUB_REPO_URL="https://github.com/Oronano/Kubernetes.git"
DOCKER_IMAGE="Oronano/Kubernetes"
NGROK_TOKEN="cr_2oNkpNcohRvzd9ZzpwD4yynOE84"

# Update the system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y docker.io kubectl jq

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Create a Kubernetes cluster
# Minikube
minikube start

# Create namespaces
kubectl create namespace $ARGOCD_NAMESPACE
kubectl create namespace $DEV_NAMESPACE

# Install Argo CD
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD pods to be ready
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $ARGOCD_NAMESPACE

# Set Argo CD admin password
argocd login localhost:8080 --username admin --password $(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NAMESPACE -o jsonpath='{.data.password}' | base64 --decode)

# Apply YAML files for Argo CD and the app
kubectl apply -f app-argo-cd.yaml -n $DEV_NAMESPACE
kubectl apply -f ingress-app.yaml -n $DEV_NAMESPACE
kubectl apply -f ingress-argocd.yaml -n $ARGOCD_NAMESPACE

# Add ngrok repository and install
sudo snap install ngrok

# Start ngrok in the background for HTTP tunneling
ngrok http 8080 &

# Install jq for JSON processing
sudo apt install -y jq

echo "Installation and configuration completed."