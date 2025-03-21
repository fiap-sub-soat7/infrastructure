#!/bin/bash
echo "-----------------------"
echo "k8s food-app deployment"
echo "-----------------------"

# application
# kubectl delete namespace --ignore-not-found=true food-app
kubectl delete all -n food-app
kubectl apply -k . -n food-app
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

while ! kubectl get pods --namespace food-app | grep -q "Running"; do
  sleep 1
done

# config for "mock nginx ingress"
kubectl port-forward service/app-nginx-lb-ingress 3000:http -n food-app

echo "-----------------------"
echo "done."