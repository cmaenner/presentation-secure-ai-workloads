# Live Demo Script

Pre-talk: Run `make bootstrap` (~5 min). Verify with `make status`.

---

## Phase 1: The Startup Default (Insecure)

**Narration**: "This is what happens when internal cluster access becomes implicit trust."

```bash
make deploy-insecure
```

Wait for pods, then:

```bash
make test-insecure
```

**Expected**: All three succeed (trusted, untrusted, attacker all get 200 OK).

**Key line**: "Everyone gets in. That's the problem."

---

## Phase 2: Apply Guardrails (Secure)

**Narration**: "I'm not adding friction to developers. I'm defining which identities are allowed to talk to sensitive services."

```bash
make deploy-secure
```

Briefly show the policies:

```bash
kubectl get ciliumnetworkpolicies -A
```

---

## Phase 3: Verify

```bash
make test-secure
```

**Expected**:
- trusted-client: 200 OK
- untrusted-client: connection timed out
- attacker: connection timed out

**Key line**: "This is the move from network location trust to policy-driven workload trust."

---

## Phase 4: Observe

```bash
make hubble-observe
```

Or manually:

```bash
cilium hubble port-forward &
hubble observe --verdict DROPPED
```

**Expected**: DROPPED verdicts from untrusted namespace to ai-demo/model-server.

**Key line**: "Controls are only real if you can verify and monitor them."

---

## If Demo Fails

- Flip to backup slides (slides 14-15 in the deck have expected terminal output)
- Keep moving: "Let me show you what this looks like..."
- The story is the same whether live or screenshots
