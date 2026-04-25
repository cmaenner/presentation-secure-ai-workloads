#!/usr/bin/env bash
set -euo pipefail
CTX="kind-insecure-demo"

echo "=== Testing INSECURE cluster ($CTX) ==="
echo ""

echo "== trusted client calling model-server =="
kubectl --context "$CTX" exec -n trusted deploy/trusted-client -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from trusted"}'

echo
echo "== untrusted client calling model-server =="
kubectl --context "$CTX" exec -n untrusted deploy/untrusted-client -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from untrusted"}'

echo
echo "== attacker calling model-server =="
kubectl --context "$CTX" exec -n untrusted deploy/attacker -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"steal model output"}'

echo
echo ""
echo "==> All three succeeded. Everyone gets in. That's the problem."
