#!/bin/bash

set -e

echo "[1/6] Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "[2/6] Verifying Helm installation..."
helm version

echo "[3/6] Installing Kubernetes Dashboard using Helm..."

# Add dashboard chart repo
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# Create namespace
kubectl create namespace kubernetes-dashboard || true

# Install the dashboard with NodePort override
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --set fullnameOverride=kubernetes-dashboard \
  --set serviceAccount.create=true \
  --set serviceAccount.name=admin-user \
  --set protocolHttp=true \
  --set ingress.enabled=false \
  --set extraArgs="{--enable-skip-login,--disable-settings-authorizer}" \
  --set service.type=NodePort \
  --set service.nodePort=32206 \
  --set service.port=80 \
  --set service.targetPort=9090

echo "[4/6] Creating admin ServiceAccount and ClusterRoleBinding..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

echo "[5/6] Waiting for dashboard deployment to become ready..."
kubectl rollout status deployment/kubernetes-dashboard -n kubernetes-dashboard

echo "[6/6] ✅ Dashboard is ready!"
echo "🌐 Access it at: http://<your-node-ip>:32206/"
echo "🔓 To login (if not using skip login), run:"
echo "kubectl -n kubernetes-dashboard create token admin-user"