# Phase 4: Observability and Close

## Narration

> "Controls are only real if you can see them working.
> Let me show you what Hubble sees."

## Commands

```bash
make hubble-observe
```

Or manually:
```bash
hubble observe --verdict DROPPED --to-namespace ai-demo
```

## Expected Output

DROPPED verdicts from untrusted/untrusted-client and untrusted/attacker
to ai-demo/model-server:8080.

## Key Lines

> "See those DROPPED verdicts? That's the untrusted client and the
> attacker being denied in real time. Not in a log file you check
> tomorrow — right now, as it happens.
>
> This is what defenders want to see. Not just 'we wrote a policy.'
> But 'here's proof it's working.'"

## Transition Back to Slides

> "So that's the demo. Three policies, one command to deploy,
> and we went from 'everything can talk to everything' to
> 'only approved identities reach sensitive workloads.'
>
> Let me leave you with a few anti-patterns to watch for..."
