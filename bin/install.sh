#!/bin/bash

if [ ! -f ./bin/values.yaml ]; then
    echo "values.yaml file not found!"
fi

echo "Installing/Updating the cluster...this can take some time"

terraform init
terraform plan -out ./dist/plan
terraform apply "./dist/plan"

echo "Installing cert-manager"

helm repo add jetstack https://charts.jetstack.io

helm install \                       
  cert-manager jetstack/cert-manager \
  --create-namespace \
  --namespace cert-manager \
  --version v1.6.1 \
  --set installCRDs=true

helm upgrade --install cert-issuer charts/cert-issuer -f values.yaml

echo "Installing https://github.com/kubernetes/ingress-nginx"

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace