# Phase 2: The Insecure State

## Narration

> "Let's see what happens when every workload in the cluster can
> talk to every other workload. No policies, no identity checks."

## Commands

```bash
make test-insecure
```

## Expected Output

All three succeed with 200 OK.

## Key Lines

> "The trusted client gets in. That's expected.
> The untrusted client also gets in. That's a problem.
> The attacker pod — just a random container with curl — also gets in.
> That's a disaster.
>
> This is the startup default. Being inside the cluster equals trust.
> And that's exactly the assumption that breaks when you add AI workloads."
