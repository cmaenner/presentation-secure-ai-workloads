# Phase 3: Applying Security Controls

## Narration

> "Now I'm going to apply three things:
> 1. A default-deny policy on the model server — nothing gets in or out.
> 2. An explicit allow for the trusted client on port 8080.
> 3. Egress rules so the trusted client can resolve DNS and reach the model.
>
> That's it. Three policies. Let's see what happens."

## Commands

```bash
make deploy-secure
```

Show the policies:
```bash
kubectl get ciliumnetworkpolicies -A
```

Then test:
```bash
make test-secure
```

## Expected Output

- trusted-client: 200 OK
- untrusted-client: connection timed out
- attacker: connection timed out

## Key Lines

> "The trusted client still gets through. Business as usual.
> The untrusted client? Timeout. The attacker? Timeout.
>
> I didn't add friction to developers. I defined which identities
> are allowed to talk to sensitive services.
>
> This is the move from network location trust to
> policy-driven workload trust. And in our production platform,
> all three of these policies are generated automatically from
> a single line in a CRD."
