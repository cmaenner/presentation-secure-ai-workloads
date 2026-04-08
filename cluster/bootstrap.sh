#!/usr/bin/env bash
# Bootstrap the local demo cluster with kind + Cilium
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLUSTER_NAME="secure-ai-demo"

# Pre-flight check
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. Start Docker Desktop first." >&2
  exit 1
fi

# Clean up existing cluster if present
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "==> Existing cluster found. Deleting..."
  kind delete cluster --name "$CLUSTER_NAME"
fi

echo "==> Creating kind cluster..."
kind create cluster --config "$REPO_ROOT/cluster/kind-config.yaml"

echo "==> Installing Cilium..."
helm repo add cilium https://helm.cilium.io 2>/dev/null || true
helm repo update cilium
helm install cilium cilium/cilium \
  --namespace kube-system \
  --values "$REPO_ROOT/cluster/cilium-values.yaml" \
  --wait --timeout 5m

echo "==> Waiting for Cilium pods..."
kubectl -n kube-system rollout status daemonset/cilium --timeout=120s

echo "==> Waiting for CoreDNS..."
kubectl -n kube-system rollout status deployment/coredns --timeout=120s

echo ""
echo "==> Cluster ready!"
kubectl get nodes
echo ""
kubectl get pods -n kube-system
