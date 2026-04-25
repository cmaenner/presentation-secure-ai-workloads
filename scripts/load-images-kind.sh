#!/usr/bin/env bash
set -euo pipefail

IMAGES=("model-server:demo" "trusted-client:demo" "untrusted-client:demo")

for cluster in insecure-demo secure-demo; do
  echo "==> Loading images into '$cluster'..."
  for img in "${IMAGES[@]}"; do
    kind load docker-image "$img" --name "$cluster"
  done
done

echo "==> All images loaded into both clusters."
