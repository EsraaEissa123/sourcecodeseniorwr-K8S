#!/bin/bash
echo "Setting up Minikube Docker environment..."
eval $(minikube docker-env)

echo "Building Application Image..."
docker build -t vprofile-app:v1 .

echo "Building Nginx Image..."
docker build -t vprofile-nginx:v1 -f Dockerfile_nginx .

echo "Deploying to Kubernetes..."
kubectl apply -f k8s/

echo "Deployment complete. Check status with 'kubectl get pods'."
