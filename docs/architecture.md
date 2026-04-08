# Architecture: Demo vs. Ybor Production Platform

This document maps the manual demo steps to what the Ybor platform automates in production. Use this as a talk-track reference.

---

## What This Demo Does Manually vs. What Ybor Automates

| Demo (Manual YAML) | Ybor Platform (Automated by Operators) |
|---|---|
| Create Namespace YAML | **Organization Operator** creates namespaces per Environment CRD |
| Create ServiceAccount YAML | **PlatformApplication Operator** auto-creates SA per app with SPIFFE identity |
| Write CiliumNetworkPolicy (default deny) | `istio_fail_closed=true` generates NetworkPolicy + AuthorizationPolicy (deny-all) |
| Write CiliumNetworkPolicy (allow trusted) | `networking.inbound.services` declaration generates AuthorizationPolicy with SPIFFE principals (`cluster.local/ns/{ns}/sa/{sa}`) |
| Write DNS egress policy | Operator generates egress rules for declared `outbound.services` |
| Label pods manually | Operator applies consistent labels from CRD metadata + `security.ybor.ai/*` |
| No mTLS | Istio PeerAuthentication (STRICT) + ambient/sidecar mesh = automatic mTLS |
| No cloud identity | IRSA (AWS) / Workload Identity (Azure) auto-provisioned per app |
| No secret management | ExternalSecrets synced from cloud secret stores |
| kubectl apply | ArgoCD + Kargo handle multi-cluster GitOps deployment |

---

## The Operator Stack

```
PlatformApplication CRD (4 lines of networking config)
    |
    v
PlatformApplication Operator (Rust)
    |
    +---> ServiceAccount
    +---> Deployment (with probes, affinity, topology spread)
    +---> NetworkPolicy (default deny + explicit allow)
    +---> AuthorizationPolicy (SPIFFE identity-based)
    +---> PeerAuthentication (mTLS STRICT)
    +---> HPA / VPA / PDB
    +---> ExternalSecrets
    +---> IRSA Role / Workload Identity
```

## Demo Talk Track

> "In this demo, I wrote 6 YAML files to secure one service.
> In production, our PlatformApplication operator generates all of this
> from a single CRD declaration. The patterns are identical —
> default deny, explicit allow, workload identity — but the operator
> makes secure the default path for every developer on the platform."

---

## Security Layers (Production)

| Layer | Component | What It Does |
|---|---|---|
| **Identity** | Istio + SPIFFE | Cryptographic workload identity via mTLS |
| **AuthZ** | AuthorizationPolicy | Allow only declared service principals |
| **Network** | NetworkPolicy | L3/L4 default deny + explicit allow |
| **Policy** | Kyverno | Cluster-wide policy enforcement |
| **Runtime** | Tetragon | eBPF-based runtime security monitoring |
| **Secrets** | External Secrets | Cloud secret store sync |
| **Certificates** | Cert Manager | Automated TLS certificate lifecycle |
| **Observability** | Hubble / Datadog | Traffic flow monitoring + anomaly detection |
