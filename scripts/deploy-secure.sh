#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CTX="kind-secure-demo"

echo "==> Deploying workloads + policies to secure cluster ($CTX)..."
kubectl --context "$CTX" apply -k "$REPO_ROOT/k8s/secure"

echo "==> Waiting for pods to be ready..."
kubectl --context "$CTX" -n ai-demo wait --for=condition=ready pod -l app=model-server --timeout=60s
kubectl --context "$CTX" -n trusted wait --for=condition=ready pod -l app=trusted-client --timeout=60s
kubectl --context "$CTX" -n untrusted wait --for=condition=ready pod -l app=untrusted-client --timeout=60s
kubectl --context "$CTX" -n untrusted wait --for=condition=ready pod -l app=attacker --timeout=60s

# Give Cilium a moment to enforce policies
sleep 3

echo ""
echo "==> Secure cluster ready. Policies enforced from the start."
kubectl --context "$CTX" get ciliumnetworkpolicies -A
