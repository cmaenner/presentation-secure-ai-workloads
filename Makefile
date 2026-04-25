.PHONY: bootstrap build-images deploy deploy-insecure deploy-secure \
        test test-insecure test-secure \
        reset-demo delete-clusters hubble-observe status

# === Pre-talk setup (run once, ~8 min) ===

bootstrap:
	./cluster/bootstrap.sh

build-images:
	./scripts/build-images.sh

# === Deploy workloads to both clusters ===

deploy: deploy-insecure deploy-secure

deploy-insecure:
	./scripts/deploy-insecure.sh

deploy-secure:
	./scripts/deploy-secure.sh

# === Demo tests ===

test: test-insecure test-secure

test-insecure:
	./scripts/test-insecure.sh

test-secure:
	./scripts/test-secure.sh

# === Cleanup ===

reset-demo:
	./scripts/reset-demo.sh

delete-clusters:
	kind delete cluster --name insecure-demo 2>/dev/null || true
	kind delete cluster --name secure-demo 2>/dev/null || true

# === Observability (secure cluster) ===

hubble-observe:
	kubectl --context kind-secure-demo -n kube-system port-forward svc/hubble-ui 12000:80 &
	@echo ""
	@echo "==> Hubble UI: http://localhost:12000/?namespace=ai-demo"
	@echo "==> Select 'ai-demo' namespace in the dropdown."

hubble-cli:
	cilium hubble port-forward --context kind-secure-demo &
	sleep 2
	hubble observe --verdict DROPPED --namespace ai-demo

# === Status ===

status:
	@echo "=== INSECURE CLUSTER ==="
	@kubectl --context kind-insecure-demo get pods -A -l 'app in (model-server,trusted-client,untrusted-client,attacker)' 2>/dev/null || echo "(cluster not running)"
	@echo ""
	@echo "=== SECURE CLUSTER ==="
	@kubectl --context kind-secure-demo get pods -A -l 'app in (model-server,trusted-client,untrusted-client,attacker)' 2>/dev/null || echo "(cluster not running)"
	@echo ""
	@echo "=== Cilium Policies (secure) ==="
	@kubectl --context kind-secure-demo get ciliumnetworkpolicies -A 2>/dev/null || echo "(none)"
