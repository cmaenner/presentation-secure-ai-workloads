# Securing AI Workloads in Kubernetes — Demo

This repository contains the live demo and slide deck for:

> **"Securing AI Workloads in Kubernetes: Lessons from Scaling Startups"**
> BSides Charm 2025 — Chris Maenner

It shows, in a simple and reproducible way, how startups typically deploy insecure workloads — and how to evolve that into a secure, policy-driven architecture **without slowing down development velocity**.

---

## What This Demo Teaches

### 1. The Startup Default (Insecure)
- Flat network — everything talks to everything
- Implicit trust inside the cluster
- Any workload can access sensitive AI services

### 2. The Problem
- AI model endpoints are high-value targets
- Prompts may contain sensitive data
- Internal services can be abused or compromised

### 3. The Fix (Secure by Default)
- Default deny network posture via CiliumNetworkPolicy
- Explicit workload-to-workload access
- Policy-driven communication with label matching
- Observability of allowed and denied traffic via Hubble

---

## Architecture

```
Namespaces:
  ai-demo     →  model-server (mock AI inference, FastAPI)
  trusted     →  trusted-client (approved workload)
  untrusted   →  untrusted-client + attacker (denied workloads)

Security labels:
  security.ybor.ai/tier: sensitive      (model-server)
  security.ybor.ai/access: approved     (trusted-client)
  security.ybor.ai/access: denied       (untrusted-client, attacker)
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

### 1. Bootstrap (run once, ~5 min)

Creates a kind cluster with Cilium CNI, builds container images, and loads them.

```bash
make bootstrap
```

### 2. Deploy Insecure Environment

```bash
make deploy-insecure
```

### 3. Test Insecure Behavior

```bash
make test-insecure
```

**Expected result — all workloads reach the model:**

```
trusted-client   → model-server  ✅ 200 OK
untrusted-client → model-server  ✅ 200 OK  (bad)
attacker         → model-server  ✅ 200 OK  (very bad)
```

### 4. Apply Security Controls

```bash
make deploy-secure
```

### 5. Test Secure Behavior

```bash
make test-secure
```

**Expected result — only trusted-client gets through:**

```
trusted-client   → model-server  ✅ 200 OK
untrusted-client → model-server  🚫 Connection timed out
attacker         → model-server  🚫 Connection timed out
```

### 6. Observe with Hubble

```bash
make hubble-observe
```

You should see `DROPPED` verdicts from the untrusted namespace.

### 7. Reset

```bash
make reset-demo
```

---

## Repository Structure

```
cluster/                 Kind + Cilium setup
  kind-config.yaml         2 workers, CNI disabled for Cilium
  cilium-values.yaml       Hubble enabled, kind-compatible settings
  bootstrap.sh             Full cluster bootstrap script

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
  load-images-kind.sh      Load images into kind cluster
  deploy-insecure.sh       Deploy without policies
  deploy-secure.sh         Deploy with Cilium policies
  test-insecure.sh         Verify all clients can reach model
  test-secure.sh           Verify only trusted client succeeds
  reset-demo.sh            Clean up all workloads

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
| `make bootstrap` | Full setup: cluster + Cilium + images (~5 min) |
| `make create-cluster` | Create kind cluster only |
| `make delete-cluster` | Delete the kind cluster |
| `make install-cilium` | Install Cilium + wait for readiness |
| `make build-images` | Build all Docker images |
| `make load-images` | Load images into kind |
| `make deploy-insecure` | Deploy workloads without policies |
| `make deploy-secure` | Deploy workloads with CiliumNetworkPolicy |
| `make test-insecure` | Test: all clients succeed |
| `make test-secure` | Test: only trusted-client succeeds |
| `make reset-demo` | Remove all workloads and policies |
| `make hubble-observe` | Start Hubble and show dropped traffic |
| `make status` | Show nodes, pods, and policies |

---

## Key Concepts Demonstrated

- Default deny networking
- Explicit workload-to-workload authorization
- Namespace is NOT a security boundary
- East-west traffic control with Cilium
- Egress control (DNS + service-level)
- Observability of service communication
- AI workloads as sensitive infrastructure

---

## Slide Deck

The presentation deck is in `.claude/decks/secure-ai-workloads/index.html`. Open it directly in a browser:

```bash
open .claude/decks/secure-ai-workloads/index.html
```

Navigate with arrow keys. Press `n` for speaker notes.

---

## For Talk Preparation

- Use `make` commands only — no long typing live
- Pre-build images before presenting (`make bootstrap`)
- Keep one terminal per phase
- Have screenshots ready as backup (slides 14-15 have expected output)
- Run `make status` to verify health before starting

---

## Closing Thought

> The goal isn't perfect security. It's building systems where
> secure is the default — and fast is still possible.
