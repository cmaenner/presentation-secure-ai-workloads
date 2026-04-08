#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Building model-server..."
docker build -t model-server:demo "$REPO_ROOT/apps/model-server/"

echo "==> Building trusted-client..."
docker build -t trusted-client:demo "$REPO_ROOT/apps/trusted-client/"

echo "==> Building untrusted-client..."
docker build -t untrusted-client:demo "$REPO_ROOT/apps/untrusted-client/"

echo ""
echo "==> All images built."
docker images | grep -E "(REPOSITORY|demo)"
