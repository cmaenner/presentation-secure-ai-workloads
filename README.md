# Securing AI Workloads in Kubernetes

This repository accompanies my conference talk, “Securing AI Workloads in Kubernetes: Lessons from Scaling Startups.” It includes the presentation, live demonstrations, and production-inspired examples showing how to build AI platforms using identity-first security, workload isolation, service meshes, observability, and GitOps. Whether you’re running startups or enterprise Kubernetes clusters, these patterns help enable developer velocity without sacrificing security.

This repository contains the live demo for:

> **"Securing AI Workloads in Kubernetes: Lessons from Scaling Startups"**

It uses **two separate Kubernetes clusters** — one insecure, one secure from birth — to show the difference between bolting on security after deployment and making secure the default.

---

## What This Demo Teaches

### 1. The Startup Default (Insecure Cluster)
- Flat network — everything talks to everything
- Implicit trust inside the cluster
- Any workload can access sensitive AI services

### 2. Secure by Default (Secure Cluster)
- Same workloads, same code — but policies ship with infrastructure
- Default deny network posture via CiliumNetworkPolicy
- Explicit workload-to-workload access
- Observability of allowed and denied traffic via Hubble

### 3. The Difference
Three CiliumNetworkPolicy files. That's it. The secure cluster was born with them. Security wasn't bolted on — it was the default.

---

## Architecture

Both clusters run identical workloads:

```
Namespaces:
  ai-demo     →  model-server (mock AI inference, FastAPI)
  trusted     →  trusted-client (approved workload)
  untrusted   →  untrusted-client + attacker (denied workloads)

Security labels:
  security.ybor.ai/tier: sensitive      (model-server)
  security.ybor.ai/access: approved     (trusted-client)
  security.ybor.ai/access: denied       (untrusted-client, attacker)

Clusters:
  insecure-demo  →  no policies (the startup default)
  secure-demo    →  CiliumNetworkPolicy enforced from the start
```

---

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [kind](https://kind.sigs.k8s.io/) — `brew install kind`
- [kubectl](https://kubernetes.io/docs/tasks/tools/) — `brew install kubectl`
- [helm](https://helm.sh/) — `brew install helm`
- [Cilium CLI](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli) (optional, for `hubble observe`)

---

## Quick Start

### 1. Bootstrap (run once, ~8 min)

Creates both kind clusters with Cilium CNI, builds container images, and loads them into each cluster.

```bash
make bootstrap
```

### 2. Deploy Workloads

Deploys the same workloads to both clusters. The insecure cluster gets no policies. The secure cluster gets CiliumNetworkPolicy enforced from the start.

```bash
make deploy
```

### 3. Test Both Clusters

```bash
make test
```

**Insecure cluster — all workloads reach the model:**

```
trusted-client   → model-server  ✅ 200 OK
untrusted-client → model-server  ✅ 200 OK  (bad)
attacker         → model-server  ✅ 200 OK  (very bad)
```

**Secure cluster — only trusted-client gets through:**

```
trusted-client   → model-server  ✅ 200 OK
untrusted-client → model-server  🚫 Connection timed out
attacker         → model-server  🚫 Connection timed out
```

### 4. Observe with Hubble UI (secure cluster)

```bash
make hubble-observe
```

Open `http://localhost:12000/?namespace=ai-demo` to see the flow map. Select the `ai-demo` namespace.

### 5. Cleanup

```bash
make delete-clusters
```

---

## Live Demo Flow

For the presentation, split the test into two commands for dramatic effect:

```bash
make test-insecure    # "Everyone gets in. That's the problem."
make test-secure      # "Security was the default. Not bolted on."
```

---

## Repository Structure

```
cluster/                 Kind + Cilium setup
  kind-config-insecure.yaml  Insecure cluster (1 CP + 1 worker)
  kind-config-secure.yaml    Secure cluster (1 CP + 1 worker)
  cilium-values.yaml         Shared Cilium config (Hubble enabled)
  bootstrap.sh               Bootstraps both clusters

apps/                    Application source code
  model-server/            FastAPI mock inference API (POST /infer, GET /healthz)
  trusted-client/          Approved client (python + curl)
  untrusted-client/        Denied client (python + curl)
  attacker/                Generic pod with curl

k8s/                     Kubernetes manifests
  base/                    Namespaces + ServiceAccounts
  apps/                    All deployment + service manifests
  insecure/                Kustomize overlay — no policies
  secure/                  Kustomize overlay — CiliumNetworkPolicy
    default-deny-ingress-egress.yaml
    allow-trusted-client-to-model.yaml
    dns-egress.yaml
  observability/           Hubble scripts + sample queries

scripts/                 Helper scripts for demo flow
  build-images.sh          Build all container images
  load-images-kind.sh      Load images into both clusters
  deploy-insecure.sh       Deploy to insecure cluster (no policies)
  deploy-secure.sh         Deploy to secure cluster (with policies)
  test-insecure.sh         Test insecure cluster — all clients succeed
  test-secure.sh           Test secure cluster — only trusted succeeds
  reset-demo.sh            Clean up workloads on both clusters

docs/                    Documentation
  architecture.md          Manual demo vs Ybor platform comparison
  demo-script.md           Step-by-step live demo script
  speaker-notes.md         Timing and delivery notes

talk-tracks/             Per-phase narration scripts
```

---

## Make Targets

| Target | What it does |
|--------|-------------|
| `make bootstrap` | Full setup: both clusters + Cilium + images (~8 min) |
| `make build-images` | Build all Docker images |
| `make deploy` | Deploy workloads to both clusters |
| `make deploy-insecure` | Deploy to insecure cluster only |
| `make deploy-secure` | Deploy to secure cluster only |
| `make test` | Test both clusters back-to-back |
| `make test-insecure` | Test insecure cluster — all clients succeed |
| `make test-secure` | Test secure cluster — only trusted succeeds |
| `make reset-demo` | Remove workloads from both clusters |
| `make delete-clusters` | Delete both kind clusters |
| `make hubble-observe` | Open Hubble UI for secure cluster |
| `make hubble-cli` | Show dropped traffic via Hubble CLI |
| `make status` | Show pods and policies on both clusters |

---

## Key Concepts Demonstrated

- Secure by default — policies ship with infrastructure, not after
- Default deny networking
- Explicit workload-to-workload authorization
- Namespace is NOT a security boundary
- East-west traffic control with Cilium
- Egress control (DNS + service-level)
- Observability of service communication
- AI workloads as sensitive infrastructure

---

## For Talk Preparation

- Run `make bootstrap && make deploy` before the talk (~8 min)
- Run `make status` to verify both clusters are healthy
- Use `make test-insecure` and `make test-secure` separately for dramatic effect
- Use `make hubble-observe` to show Hubble UI on the secure cluster
- Have a backup terminal ready in case Docker restarts (`make bootstrap` recovers in ~8 min)

---

## Closing Thought

> The goal isn't perfect security. It's building systems where
> secure is the default — and fast is still possible.
