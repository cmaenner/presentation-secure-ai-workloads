#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Resetting insecure cluster..."
kubectl --context kind-insecure-demo delete -k "$REPO_ROOT/k8s/insecure" --ignore-not-found=true 2>/dev/null || true

echo "==> Resetting secure cluster..."
kubectl --context kind-secure-demo delete -k "$REPO_ROOT/k8s/secure" --ignore-not-found=true 2>/dev/null || true

echo "==> Both clusters reset."
