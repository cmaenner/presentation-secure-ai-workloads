#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Deploying insecure configuration..."
kubectl apply -k "$REPO_ROOT/k8s/insecure"

echo "==> Waiting for pods to be ready..."
kubectl -n ai-demo wait --for=condition=ready pod -l app=model-server --timeout=60s
kubectl -n trusted wait --for=condition=ready pod -l app=trusted-client --timeout=60s
kubectl -n untrusted wait --for=condition=ready pod -l app=untrusted-client --timeout=60s
kubectl -n untrusted wait --for=condition=ready pod -l app=attacker --timeout=60s

echo ""
echo "==> All workloads running (insecure mode)."
kubectl get pods -A -l 'app in (model-server,trusted-client,untrusted-client,attacker)'
