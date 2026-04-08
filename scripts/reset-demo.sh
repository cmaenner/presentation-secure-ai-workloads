#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Resetting demo..."
kubectl delete -k "$REPO_ROOT/k8s/secure" --ignore-not-found=true 2>/dev/null || true
kubectl delete -k "$REPO_ROOT/k8s/insecure" --ignore-not-found=true 2>/dev/null || true

echo "==> Demo reset. Cluster is clean."
