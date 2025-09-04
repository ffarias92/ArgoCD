#!/bin/bash

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl get namespaces > namespaces.txt

NAMESPACE=argocd

if grep -q "$NAMESPACE" namespaces.txt; then
  echo "El namespace '$NAMESPACE' ya existe, Saltando!"
else
  echo "El namespace '$NAMESPACE' no existe, Creando...!, espere unos segundos!"
  kubectl create namespace argocd
  echo "El namespace '$NAMESPACE' fue creado exitosamente."
fi

helm install argocd argo/argo-cd 

kubectl  apply -f argocd-service.yaml
kubectl port-forward service/argocd-server -n argocd --address 192.168.1.93 8080:443

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo


