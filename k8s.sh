#!/bin/bash
echo "-----------------------"
echo "k8s vehicle-app deployment"
echo "-----------------------"

# application
# kubectl delete namespace --ignore-not-found=true vehicle-app
kubectl delete all -n vehicle-app
kubectl apply -k . -n vehicle-app
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

while ! kubectl get pods --namespace vehicle-app | grep -q "Running"; do
  sleep 1
done

# config for "mock nginx ingress"
kubectl port-forward service/app-nginx-lb-ingress 3000:http -n vehicle-app

echo "-----------------------"
echo "done."