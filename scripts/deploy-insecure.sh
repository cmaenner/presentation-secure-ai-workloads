#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CTX="kind-insecure-demo"

echo "==> Deploying workloads to insecure cluster ($CTX)..."
kubectl --context "$CTX" apply -k "$REPO_ROOT/k8s/insecure"

echo "==> Waiting for pods to be ready..."
kubectl --context "$CTX" -n ai-demo wait --for=condition=ready pod -l app=model-server --timeout=60s
kubectl --context "$CTX" -n trusted wait --for=condition=ready pod -l app=trusted-client --timeout=60s
kubectl --context "$CTX" -n untrusted wait --for=condition=ready pod -l app=untrusted-client --timeout=60s
kubectl --context "$CTX" -n untrusted wait --for=condition=ready pod -l app=attacker --timeout=60s

echo ""
echo "==> Insecure cluster ready. No policies applied."
kubectl --context "$CTX" get pods -A -l 'app in (model-server,trusted-client,untrusted-client,attacker)'
