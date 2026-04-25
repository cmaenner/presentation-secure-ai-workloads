#!/usr/bin/env bash
# Bootstrap both demo clusters: insecure-demo and secure-demo
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CLUSTERS=("insecure-demo" "secure-demo")

# Pre-flight check
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. Start Docker Desktop first." >&2
  exit 1
fi

# Helper: bootstrap a single cluster
bootstrap_cluster() {
  local name="$1"
  local config="$REPO_ROOT/cluster/kind-config-${name%%-demo}.yaml"
  local context="kind-${name}"

  echo ""
  echo "========================================="
  echo "  Bootstrapping: $name"
  echo "========================================="

  # Clean up existing cluster if present
  if kind get clusters 2>/dev/null | grep -q "^${name}$"; then
    echo "==> Existing cluster '$name' found. Deleting..."
    kind delete cluster --name "$name"
  fi

  echo "==> Creating kind cluster '$name'..."
  kind create cluster --config "$config"

  echo "==> Installing Cilium on '$name'..."
  helm repo add cilium https://helm.cilium.io 2>/dev/null || true
  helm repo update cilium
  kubectl --context "$context" get nodes >/dev/null 2>&1
  helm install cilium cilium/cilium \
    --kube-context "$context" \
    --namespace kube-system \
    --values "$REPO_ROOT/cluster/cilium-values.yaml" \
    --set k8sServiceHost="${name}-control-plane" \
    --set k8sServicePort=6443 \
    --wait --timeout 5m

  echo "==> Waiting for Cilium on '$name'..."
  kubectl --context "$context" -n kube-system rollout status daemonset/cilium --timeout=120s

  echo "==> Waiting for CoreDNS on '$name'..."
  kubectl --context "$context" -n kube-system rollout status deployment/coredns --timeout=120s

  echo "==> Loading images into '$name'..."
  kind load docker-image model-server:demo --name "$name"
  kind load docker-image trusted-client:demo --name "$name"
  kind load docker-image untrusted-client:demo --name "$name"

  echo "==> '$name' ready."
}

# Build images once (shared across both clusters)
echo "==> Building container images..."
"$REPO_ROOT/scripts/build-images.sh"

# Bootstrap both clusters
for cluster in "${CLUSTERS[@]}"; do
  bootstrap_cluster "$cluster"
done

echo ""
echo "========================================="
echo "  Both clusters ready!"
echo "========================================="
echo ""
echo "  make deploy    — deploy workloads to both clusters"
echo "  make test      — test both clusters"
