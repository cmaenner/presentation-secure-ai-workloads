#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="${CLUSTER_NAME:-secure-ai-demo}"

echo "==> Loading images into kind cluster '$CLUSTER_NAME'..."
kind load docker-image model-server:demo --name "$CLUSTER_NAME"
kind load docker-image trusted-client:demo --name "$CLUSTER_NAME"
kind load docker-image untrusted-client:demo --name "$CLUSTER_NAME"

echo "==> All images loaded."
