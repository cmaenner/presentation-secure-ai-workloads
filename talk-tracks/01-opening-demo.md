# Phase 1: Opening the Demo

## Setup

Before presenting, run:
```bash
make bootstrap
make status
```

## Narration

> "I've got a local Kubernetes cluster running with Cilium as the CNI.
> Inside, there's a mock AI inference service — think of it as your
> model endpoint, the thing that processes prompts and returns responses.
>
> There's also a trusted client that's supposed to access it,
> an untrusted client that shouldn't, and an attacker pod —
> just a container with curl, sitting inside the cluster."

## Commands

```bash
make deploy-insecure
make status
```

> "Notice the labels: `security.ybor.ai/tier: sensitive` on the model server,
> `access: approved` on the trusted client, `access: denied` on the rest.
> Right now, those labels are just metadata. They don't enforce anything."
