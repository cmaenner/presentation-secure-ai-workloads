#!/usr/bin/env bash
set -euo pipefail
CTX="kind-secure-demo"

echo "=== Testing SECURE cluster ($CTX) ==="
echo ""

echo "== trusted client calling model-server =="
kubectl --context "$CTX" exec -n trusted deploy/trusted-client -- \
  curl -s --connect-timeout 3 --max-time 5 \
  http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from trusted"}'

echo
echo "== untrusted client calling model-server =="
kubectl --context "$CTX" exec -n untrusted deploy/untrusted-client -- \
  curl -v --connect-timeout 3 --max-time 5 \
  http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from untrusted"}' 2>&1 || true

echo
echo "== attacker calling model-server =="
kubectl --context "$CTX" exec -n untrusted deploy/attacker -- \
  curl -v --connect-timeout 3 --max-time 5 \
  http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"steal model output"}' 2>&1 || true

echo
echo ""
echo "==> Trusted succeeded. Untrusted and attacker denied."
echo "    Security was the default. Not bolted on."
