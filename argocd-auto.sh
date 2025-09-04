#!/bin/bash

NAMESPACE=argocd

if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "El namespace '$NAMESPACE' ya existe, saltando!"
else
  echo "El namespace '$NAMESPACE' no existe, Creando...!, espere unos segundos!"
  kubectl create namespace argocd
  echo "El namespace '$NAMESPACE' fue creado exitosamente."
fi

echo "Instalando ArgoCD con ayudita de Helm"

helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm install argocd argo/argo-cd --namespace argocd \
  --set server.service.type=ClusterIP \
  --wait >/dev/null 2>&1

echo "ArgoCD se ha instalado exitosamente. Creando Pods!"

MINIKUBE_HOST_IP=$(hostname -I | awk '{print $1}')

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s >/dev/null 2>&1

echo "ArgoCD listo!, iniciando Port-forward"

kubectl port-forward service/argocd-server -n argocd --address $MINIKUBE_HOST_IP 8080:443 &

echo "Interfaz de ArgoCD : https://$MINIKUBE_HOST_IP:8080"

PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Credenciales -> usuario  : admin"
echo "             -> password : $PASSWORD"

