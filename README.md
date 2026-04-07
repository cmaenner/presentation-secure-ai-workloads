# Securing AI Workloads in Kubernetes — Demo

This repository contains the live demo used in the talk:

> **“Securing AI Workloads in Kubernetes: Lessons from Scaling Startups”**

It is designed to show, in a simple and reproducible way, how startups typically deploy insecure workloads—and how to evolve that into a secure, identity- and policy-driven architecture **without slowing down development velocity**.

---

# 🧠 What This Demo Teaches

This demo walks through a real-world progression:

### 1. The Startup Default (Insecure)
- Flat network
- Implicit trust inside the cluster
- Any workload can access sensitive services

### 2. The Problem
- AI model endpoints become high-value targets
- Prompts may contain sensitive data
- Internal services can be abused or compromised

### 3. The Fix (Secure by Default)
- Default deny network posture
- Explicit workload-to-workload access
- Policy-driven communication
- Observability of allowed and denied traffic

---

# 🧱 Architecture Overview

The demo simulates a simple AI platform:

- **model-server** → Represents an AI inference service
- **trusted-client** → A legitimate internal service
- **untrusted-client** → A service that should NOT have access
- **attacker** → A generic pod attempting lateral movement

Namespaces:

- `ai-demo` → sensitive AI workload
- `trusted` → approved workloads
- `untrusted` → non-approved workloads

---

# ⚙️ Requirements

You will need:

- Docker
- `kind`
- `kubectl`
- `helm`
- (Optional but recommended) `cilium` CLI

---

# 🚀 Quick Start

## 1. Create Cluster

```bash
make create-cluster

2. Install Cilium

make install-cilium

3. Build and Load Images

make build-images
make load-images

4. Deploy Insecure Environment

make deploy-insecure

5. Test Insecure Behavior

make test-insecure

Expected Result

All workloads can access the model:
	•	✅ trusted-client → allowed
	•	❌ untrusted-client → also allowed (bad)
	•	❌ attacker → also allowed (very bad)

This represents the default startup reality.

⸻

🔐 Apply Security Controls

Deploy Secure Configuration

make deploy-secure

Test Secure Behavior

make test-secure

Expected Result
	•	✅ trusted-client → allowed
	•	🚫 untrusted-client → denied
	•	🚫 attacker → denied

This demonstrates:

Workload identity + policy > network location trust

⸻

🔍 Observability (Hubble)

Observe traffic in real time:

cilium hubble port-forward &
hubble observe

View Dropped Traffic

hubble observe --verdict DROPPED

You should see:
	•	denied connections from untrusted namespace
	•	enforcement of policy at runtime

⸻

🧪 Demo Flow (For Presentations)

Phase 1 — Insecure

make deploy-insecure
make test-insecure

Narrative:

“Everything can talk to everything. This is where most startups start.”

⸻

Phase 2 — Secure

make deploy-secure
make test-secure

Narrative:

“We introduce guardrails—not friction. Only approved identities can access sensitive workloads.”

⸻

Phase 3 — Observe

hubble observe --verdict DROPPED

Narrative:

“Controls are only real if you can see them working.”

⸻

📁 Repository Structure

cluster/        → kind + Cilium setup
apps/           → model + client workloads
k8s/            → base, insecure, and secure manifests
scripts/        → helper scripts for demo flow
docs/           → speaker notes, diagrams, screenshots
talk-tracks/    → narrative for presenting demo live


⸻

🧠 Key Concepts Demonstrated
	•	Default deny networking
	•	Explicit workload-to-workload authorization
	•	Namespace is NOT a security boundary
	•	East-west traffic control
	•	Observability of service communication
	•	AI workloads as sensitive infrastructure

⸻

⚠️ Anti-Patterns This Demo Highlights
	•	“Everything inside the cluster is trusted”
	•	Over-permissioned service accounts
	•	No egress control
	•	Treating AI services like normal microservices
	•	Adding security “later”

⸻

🧩 Extending This Demo

Future enhancements:
	•	SPIFFE/SPIRE for workload identity
	•	Istio mTLS + AuthorizationPolicy
	•	Prompt-level protections
	•	Token usage monitoring
	•	Rate limiting for inference endpoints

⸻

🎤 For Talk Preparation

If you’re using this for a presentation:
	•	Use make commands only (no long typing live)
	•	Pre-build images before presenting
	•	Keep one terminal per phase
	•	Have screenshots ready as backup

⸻

🙌 Final Thought

Secure systems are not built by adding controls later.
They are built by making secure the default path.

⸻

📄 License

MIT (or update based on your preference)
