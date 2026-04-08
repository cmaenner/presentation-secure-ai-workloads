# Hubble Observability Queries

## All flows to/from model-server
```bash
hubble observe --namespace ai-demo
```

## Denied connections only
```bash
hubble observe --verdict DROPPED
```

## Denied connections to AI namespace specifically
```bash
hubble observe --verdict DROPPED --to-namespace ai-demo
```

## Attacker attempts from untrusted namespace
```bash
hubble observe --from-namespace untrusted --to-namespace ai-demo
```

## Allowed flows to model-server
```bash
hubble observe --verdict FORWARDED --to-namespace ai-demo
```
