#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Removing insecure configuration..."
kubectl delete -k "$REPO_ROOT/k8s/insecure" --ignore-not-found=true

echo "==> Deploying secure configuration..."
kubectl apply -k "$REPO_ROOT/k8s/secure"

echo "==> Waiting for pods to be ready..."
kubectl -n ai-demo wait --for=condition=ready pod -l app=model-server --timeout=60s
kubectl -n trusted wait --for=condition=ready pod -l app=trusted-client --timeout=60s

# Give Cilium a moment to enforce new policies
sleep 3

echo ""
echo "==> Secure configuration deployed."
kubectl get ciliumnetworkpolicies -A
