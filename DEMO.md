# Demo Repo Design: Securing AI Workloads in Kubernetes

This repo should optimize for four things:

1. **Fast local setup**
2. **Clear insecure → secure progression**
3. **Minimal moving parts during a live demo**
4. **Reusable material for future talks**

The audience should be able to understand the story just by looking at the folders.

---

# Demo Story

The demo should walk through this sequence:

1. Deploy a local Kubernetes cluster
2. Run a simple AI-style inference service with no protections
3. Show that any service can call it
4. Introduce identity and policy controls
5. Show only approved workloads can access it
6. Show observability of allowed and denied traffic

You do not need a real LLM for the first version. A lightweight mock inference API is better for reliability and speed.

---

# Recommended Stack

## Local platform
- `kind` for cluster creation
- `kubectl`
- `helm`

## Security/data plane
Choose one primary path for the live talk:

### Best live demo path
- **Cilium**
- Use:
  - Hubble for observability
  - Cilium NetworkPolicy / CiliumClusterwideNetworkPolicy
  - Optional mutual auth story through service identity concepts

### Optional second path for future versions
- **Istio**
- Use:
  - PeerAuthentication
  - AuthorizationPolicy
  - RequestAuthentication if needed

For the first talk, I would keep the live demo focused on **Cilium** because:
- fewer moving pieces than full SPIRE + Istio
- easier local install
- strong visual story for east-west controls and observability

Then you can **talk about SPIFFE/SPIRE and mTLS conceptually**, while showing a clean access-control demo locally.

If you want, later we can add a second branch for `istio-spiffe`.

---

# Repo Structure

```text
secure-ai-workloads-demo/
├── README.md
├── Makefile
├── .env.example
├── docs/
│   ├── demo-script.md
│   ├── speaker-notes.md
│   ├── architecture.md
│   └── backup-slides-assets/
│       ├── insecure-call.png
│       ├── denied-call.png
│       └── hubble-flow.png
├── cluster/
│   ├── kind-config.yaml
│   ├── cilium-values.yaml
│   └── bootstrap.sh
├── apps/
│   ├── model-server/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   └── k8s/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       └── namespace.yaml
│   ├── trusted-client/
│   │   ├── Dockerfile
│   │   ├── client.py
│   │   └── k8s/
│   │       ├── deployment.yaml
│   │       └── serviceaccount.yaml
│   ├── untrusted-client/
│   │   ├── Dockerfile
│   │   ├── client.py
│   │   └── k8s/
│   │       ├── deployment.yaml
│   │       └── serviceaccount.yaml
│   └── attacker/
│       ├── Dockerfile
│       ├── shell.sh
│       └── k8s/
│           ├── deployment.yaml
│           └── serviceaccount.yaml
├── k8s/
│   ├── base/
│   │   ├── namespaces.yaml
│   │   ├── serviceaccounts.yaml
│   │   └── kustomization.yaml
│   ├── insecure/
│   │   ├── kustomization.yaml
│   │   └── allow-all.yaml
│   ├── secure/
│   │   ├── kustomization.yaml
│   │   ├── default-deny-ingress-egress.yaml
│   │   ├── allow-trusted-client-to-model.yaml
│   │   ├── block-untrusted-client.yaml
│   │   └── dns-egress.yaml
│   └── observability/
│       ├── hubble-port-forward.sh
│       └── sample-queries.md
├── scripts/
│   ├── build-images.sh
│   ├── load-images-kind.sh
│   ├── deploy-insecure.sh
│   ├── deploy-secure.sh
│   ├── test-insecure.sh
│   ├── test-secure.sh
│   └── reset-demo.sh
└── talk-tracks/
    ├── 01-opening-demo.md
    ├── 02-insecure-state.md
    ├── 03-secure-state.md
    └── 04-observability-close.md


⸻

What Each Component Does

model-server

This is your “AI workload.”

Keep it very simple:
	•	POST /infer
	•	accepts JSON like:

{"prompt":"Summarize this startup risk"}


	•	returns:

{"result":"mock-model-output","model":"demo-llm-v1"}



You can also add:
	•	/healthz
	•	/metrics if you want to show request counts later

This service represents:
	•	a model endpoint
	•	sensitive prompts
	•	expensive compute target

⸻

trusted-client

This is the approved internal service.

It should:
	•	send a request to the model server
	•	succeed in the secure state

This represents:
	•	a real application tier that is supposed to access the model

⸻

untrusted-client

This is a workload in the cluster that should not be able to call the model.

It should:
	•	succeed in insecure mode
	•	fail in secure mode

This is one of your best story elements.

⸻

attacker

This can just be a BusyBox/alpine-style pod with curl.

Use it to show:
	•	a random pod inside the cluster can often reach sensitive services
	•	“being inside the cluster” should not equal trust

⸻

Namespace Design

Keep namespaces simple and intentional.

ai-demo
trusted
untrusted
observability

Suggested usage
	•	ai-demo: model server
	•	trusted: trusted client
	•	untrusted: untrusted client + attacker
	•	observability is optional if tooling needs a home

This lets you tell a clean story:
	•	workload identity starts with placement and labeling
	•	namespaces are not enough on their own
	•	policy is what creates real boundaries

⸻

Labeling Strategy

Use labels consistently because your policies and observability will rely on them.

Recommended labels:

app: model-server
app: trusted-client
app: untrusted-client
app: attacker

security.ybor.ai/tier: sensitive
security.ybor.ai/access: approved
security.ybor.ai/access: denied

Example:
	•	model-server gets security.ybor.ai/tier: sensitive
	•	trusted-client gets security.ybor.ai/access: approved
	•	untrusted-client gets security.ybor.ai/access: denied

This makes the story visible.

⸻

Base Kubernetes YAML

k8s/base/namespaces.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: ai-demo
---
apiVersion: v1
kind: Namespace
metadata:
  name: trusted
---
apiVersion: v1
kind: Namespace
metadata:
  name: untrusted


⸻

k8s/base/serviceaccounts.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: model-server
  namespace: ai-demo
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: trusted-client
  namespace: trusted
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: untrusted-client
  namespace: untrusted
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: attacker
  namespace: untrusted


⸻

Model Server YAML

apps/model-server/k8s/namespace.yaml

You can omit this if you use the shared base namespaces.

apps/model-server/k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-server
  namespace: ai-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: model-server
  template:
    metadata:
      labels:
        app: model-server
        security.ybor.ai/tier: sensitive
    spec:
      serviceAccountName: model-server
      containers:
        - name: model-server
          image: model-server:demo
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: MODEL_NAME
              value: demo-llm-v1
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10

apps/model-server/k8s/service.yaml

apiVersion: v1
kind: Service
metadata:
  name: model-server
  namespace: ai-demo
spec:
  selector:
    app: model-server
  ports:
    - name: http
      port: 8080
      targetPort: 8080


⸻

Trusted Client YAML

apps/trusted-client/k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: trusted-client
  namespace: trusted
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trusted-client
  template:
    metadata:
      labels:
        app: trusted-client
        security.ybor.ai/access: approved
    spec:
      serviceAccountName: trusted-client
      containers:
        - name: trusted-client
          image: trusted-client:demo
          imagePullPolicy: IfNotPresent
          command: ["sleep", "3600"]


⸻

Untrusted Client YAML

apps/untrusted-client/k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: untrusted-client
  namespace: untrusted
spec:
  replicas: 1
  selector:
    matchLabels:
      app: untrusted-client
  template:
    metadata:
      labels:
        app: untrusted-client
        security.ybor.ai/access: denied
    spec:
      serviceAccountName: untrusted-client
      containers:
        - name: untrusted-client
          image: untrusted-client:demo
          imagePullPolicy: IfNotPresent
          command: ["sleep", "3600"]


⸻

Attacker Pod YAML

apps/attacker/k8s/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: attacker
  namespace: untrusted
spec:
  replicas: 1
  selector:
    matchLabels:
      app: attacker
  template:
    metadata:
      labels:
        app: attacker
        security.ybor.ai/access: denied
    spec:
      serviceAccountName: attacker
      containers:
        - name: attacker
          image: curlimages/curl:8.7.1
          imagePullPolicy: IfNotPresent
          command: ["sleep", "3600"]


⸻

Insecure Mode

This should intentionally allow access by default.

k8s/insecure/kustomization.yaml

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base/namespaces.yaml
  - ../base/serviceaccounts.yaml
  - ../../apps/model-server/k8s/deployment.yaml
  - ../../apps/model-server/k8s/service.yaml
  - ../../apps/trusted-client/k8s/deployment.yaml
  - ../../apps/untrusted-client/k8s/deployment.yaml
  - ../../apps/attacker/k8s/deployment.yaml

That is enough. No policy means cluster networking allows the story:
	•	trusted client works
	•	untrusted client also works
	•	attacker works too

That is your “bad startup default.”

⸻

Secure Mode

The secure mode should do three things:
	1.	default deny
	2.	explicitly allow trusted client to model server
	3.	permit only required egress like DNS

Because you are using Cilium, use CiliumNetworkPolicy.

⸻

k8s/secure/default-deny-ingress-egress.yaml

apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: default-deny-model-server
  namespace: ai-demo
spec:
  endpointSelector:
    matchLabels:
      app: model-server
  ingress: []
  egress: []

This locks down the model server.

⸻

k8s/secure/allow-trusted-client-to-model.yaml

apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-trusted-client-to-model
  namespace: ai-demo
spec:
  endpointSelector:
    matchLabels:
      app: model-server
  ingress:
    - fromEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: trusted
            app: trusted-client
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP

This is the money slide in YAML form:
	•	only trusted namespace
	•	only trusted client
	•	only port 8080

⸻

k8s/secure/block-untrusted-client.yaml

You may not need an explicit block if default deny is already active. That said, having a named artifact can help teaching.

apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: block-untrusted-namespace
  namespace: ai-demo
spec:
  endpointSelector:
    matchLabels:
      app: model-server
  ingress:
    - fromEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: trusted
            app: trusted-client

This overlaps with the allow policy and reinforces the point.

⸻

k8s/secure/dns-egress.yaml

If any pods need DNS resolution, add this to their namespaces.

Example for trusted client:

apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: trusted-client-dns-egress
  namespace: trusted
spec:
  endpointSelector:
    matchLabels:
      app: trusted-client
  egress:
    - toEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: kube-system
            k8s-app: kube-dns
      toPorts:
        - ports:
            - port: "53"
              protocol: UDP
            - port: "53"
              protocol: TCP

This is a very useful teaching moment:

“Network policy without egress thinking is one of the most common false wins in Kubernetes security.”

⸻

k8s/secure/kustomization.yaml

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base/namespaces.yaml
  - ../base/serviceaccounts.yaml
  - ../../apps/model-server/k8s/deployment.yaml
  - ../../apps/model-server/k8s/service.yaml
  - ../../apps/trusted-client/k8s/deployment.yaml
  - ../../apps/untrusted-client/k8s/deployment.yaml
  - ../../apps/attacker/k8s/deployment.yaml
  - default-deny-ingress-egress.yaml
  - allow-trusted-client-to-model.yaml
  - dns-egress.yaml


⸻

Kind Cluster Config

cluster/kind-config.yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: secure-ai-demo
nodes:
  - role: control-plane
  - role: worker
  - role: worker
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"

This is suitable if you want Cilium as the CNI.

⸻

Cilium Values

cluster/cilium-values.yaml

ipam:
  mode: kubernetes

hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true

operator:
  replicas: 1

k8sServiceHost: secure-ai-demo-control-plane
k8sServicePort: 6443

Depending on your install method, you may not need all of this, but keeping explicit values helps repeatability.

⸻

Makefile

Keep the commands dead simple because this will help you both live and in rehearsal.

Makefile

CLUSTER_NAME=secure-ai-demo

create-cluster:
	kind create cluster --config cluster/kind-config.yaml

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

install-cilium:
	helm repo add cilium https://helm.cilium.io
	helm repo update
	helm install cilium cilium/cilium \
	  --namespace kube-system \
	  --values cluster/cilium-values.yaml

build-images:
	./scripts/build-images.sh

load-images:
	./scripts/load-images-kind.sh

deploy-insecure:
	kubectl apply -k k8s/insecure

deploy-secure:
	kubectl delete -k k8s/insecure --ignore-not-found=true
	kubectl apply -k k8s/secure

test-insecure:
	./scripts/test-insecure.sh

test-secure:
	./scripts/test-secure.sh

reset-demo:
	./scripts/reset-demo.sh


⸻

Suggested Scripts

scripts/test-insecure.sh

This should produce your “bad” result.

#!/usr/bin/env bash
set -euo pipefail

echo "== trusted client calling model-server =="
kubectl exec -n trusted deploy/trusted-client -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from trusted"}'

echo
echo "== untrusted client calling model-server =="
kubectl exec -n untrusted deploy/untrusted-client -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from untrusted"}'

echo
echo "== attacker calling model-server =="
kubectl exec -n untrusted deploy/attacker -- \
  curl -s http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"steal model output"}'

Expected outcome:
	•	all three succeed

That is exactly the point.

⸻

scripts/test-secure.sh

#!/usr/bin/env bash
set -euo pipefail

echo "== trusted client calling model-server =="
kubectl exec -n trusted deploy/trusted-client -- \
  curl -s --max-time 5 http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from trusted"}'

echo
echo "== untrusted client calling model-server =="
kubectl exec -n untrusted deploy/untrusted-client -- \
  curl -v --max-time 5 http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"hello from untrusted"}' || true

echo
echo "== attacker calling model-server =="
kubectl exec -n untrusted deploy/attacker -- \
  curl -v --max-time 5 http://model-server.ai-demo.svc.cluster.local:8080/infer \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"steal model output"}' || true

Expected outcome:
	•	trusted succeeds
	•	untrusted fails
	•	attacker fails

That is your strongest live moment.

⸻

Application Code Guidance

model-server/app.py

Use FastAPI.

Suggested endpoints:
	•	GET /healthz
	•	POST /infer

Behavior:
	•	log the caller prompt
	•	return mock inference output
	•	maybe add a fake “token_count” field for storytelling

Example response:

{
  "model": "demo-llm-v1",
  "result": "Mock response for: hello from trusted",
  "token_count": 42
}

This lets you talk about:
	•	prompt sensitivity
	•	token/cost abuse
	•	inference visibility

⸻

trusted-client/client.py and untrusted-client/client.py

You do not need much here. These images can just include curl or Python requests. Their deployments mostly exist so you can exec into them during the demo.

⸻

Demo Flow You Can Narrate Live

Phase 1: “Here’s the startup default”
	•	deploy insecure
	•	exec from trusted client
	•	exec from untrusted client
	•	exec from attacker

Narration:

“This is what happens when internal cluster access becomes implicit trust.”

Phase 2: “Now we apply guardrails”
	•	switch to secure manifests
	•	explain default deny
	•	explain explicit allow

Narration:

“I’m not adding friction to developers. I’m defining which identities are allowed to talk to sensitive services.”

Phase 3: “Now let’s verify”
	•	trusted succeeds
	•	untrusted denied
	•	attacker denied

Narration:

“This is the move from network location trust to policy-driven workload trust.”

Phase 4: “Now let’s observe it”
	•	Hubble UI or CLI
	•	show allowed and dropped flows

Narration:

“Controls are only real if you can verify and monitor them.”

⸻

Hubble Observability

This is worth including because it makes the demo visual.

Example commands

cilium hubble port-forward&
hubble observe --namespace ai-demo

Or filter dropped traffic:

hubble observe --verdict DROPPED

This is powerful because you can show:
	•	denied access attempts
	•	which namespace tried to call the sensitive service
	•	traffic after policy was applied

That lands really well with defenders.

⸻

README Structure

Your README should make it easy for attendees to try it later.

Recommended sections:

# Securing AI Workloads in Kubernetes Demo

## What this demo shows
- insecure east-west access
- policy-driven workload isolation
- observability with Hubble

## Requirements
- Docker
- kind
- kubectl
- helm
- cilium CLI (optional)

## Quick Start
make create-cluster
make install-cilium
make build-images
make load-images
make deploy-insecure
make test-insecure

## Apply secure controls
make deploy-secure
make test-secure

## Observability
hubble observe --verdict DROPPED


⸻

Important Live-Demo Design Rules

1. Do not build images live

Build before the talk.

2. Do not type long commands live

Use short make targets or pre-staged terminals.

3. Keep the “AI” part conceptual, not compute-heavy

A mock inference API is enough.

4. Have a backup plan

Save:
	•	terminal screenshots
	•	YAML screenshots
	•	Hubble screenshot

5. Keep policies small enough to fit on a slide

The audience should see:
	•	default deny
	•	explicit allow

That is enough.

⸻

Recommended V1 Scope

For your first public run of this talk, I would ship V1 like this:

Include live
	•	kind
	•	Cilium
	•	model server
	•	trusted client
	•	untrusted client
	•	default deny
	•	allow trusted client
	•	Hubble dropped flow view

Mention verbally, not live
	•	SPIFFE/SPIRE
	•	full mTLS rollout
	•	Istio AuthorizationPolicy
	•	prompt/embedding encryption patterns

That keeps the live demo stable while preserving depth in the talk.

⸻

Recommended V2 Scope Later

After BSides Charm, evolve the repo into branches:

main               -> Cilium policy demo
feature/istio      -> Istio mTLS + AuthorizationPolicy
feature/spire      -> SPIFFE/SPIRE identity
feature/observability -> richer AI abuse metrics

This will let you reuse the same story across multiple conferences.

⸻

My Recommendation for Your Next Step

Build this in order:
	1.	kind cluster + Cilium install
	2.	model-server
	3.	trusted-client and untrusted-client
	4.	insecure deploy
	5.	secure deploy
	6.	Hubble output
	7.	README and demo-script

The next thing I’d work on is the actual model-server app and the Makefile/scripts so the repo becomes runnable end to end.

Next, I can draft the actual FastAPI app plus the Makefile and shell scripts so you have a working v1 skeleton.
