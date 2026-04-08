CLUSTER_NAME = secure-ai-demo

.PHONY: bootstrap create-cluster delete-cluster install-cilium \
        build-images load-images \
        deploy-insecure deploy-secure test-insecure test-secure \
        reset-demo hubble-observe status

# === Pre-talk setup (run once) ===

bootstrap: create-cluster install-cilium build-images load-images
	@echo ""
	@echo "==> Cluster fully bootstrapped."
	@echo "    Run 'make deploy-insecure' to start the demo."

create-cluster:
	kind create cluster --config cluster/kind-config.yaml

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

install-cilium:
	helm repo add cilium https://helm.cilium.io 2>/dev/null || true
	helm repo update cilium
	helm install cilium cilium/cilium \
	  --namespace kube-system \
	  --values cluster/cilium-values.yaml \
	  --wait --timeout 5m
	kubectl -n kube-system rollout status daemonset/cilium --timeout=120s
	kubectl -n kube-system rollout status deployment/coredns --timeout=120s

build-images:
	./scripts/build-images.sh

load-images:
	./scripts/load-images-kind.sh

# === Demo flow ===

deploy-insecure:
	./scripts/deploy-insecure.sh

deploy-secure:
	./scripts/deploy-secure.sh

test-insecure:
	./scripts/test-insecure.sh

test-secure:
	./scripts/test-secure.sh

reset-demo:
	./scripts/reset-demo.sh

# === Observability ===

hubble-observe:
	cilium hubble port-forward &
	sleep 2
	hubble observe --verdict DROPPED --namespace ai-demo

# === Utility ===

status:
	@echo "=== Nodes ==="
	@kubectl get nodes
	@echo ""
	@echo "=== Demo Pods ==="
	@kubectl get pods -A -l 'app in (model-server,trusted-client,untrusted-client,attacker)'
	@echo ""
	@echo "=== Cilium Policies ==="
	@kubectl get ciliumnetworkpolicies -A 2>/dev/null || echo "(none)"
