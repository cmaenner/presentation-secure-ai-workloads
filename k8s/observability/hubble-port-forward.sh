#!/usr/bin/env bash
echo "==> Starting Hubble relay port-forward..."
cilium hubble port-forward &
sleep 2
echo "==> Hubble ready. Try:"
echo "  hubble observe --namespace ai-demo"
echo "  hubble observe --verdict DROPPED"
echo "  hubble observe --verdict DROPPED --to-namespace ai-demo"
echo "  hubble observe --from-namespace untrusted --to-namespace ai-demo"
