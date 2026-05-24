# Policy as Code — Kyverno Policies

Security policies enforced at Kubernetes admission control.

Ref: https://kyverno.io/

## Installation

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

## Policies

| Policy | Action | Severity | Description |
|---|---|---|---|
| `disallow-root-containers` | Enforce | HIGH | Block containers running as root |
| `require-resource-limits` | Enforce | MEDIUM | CPU and memory requests/limits required |
| `require-probes` | Enforce | MEDIUM | Readiness and liveness probes required |
| `disallow-latest-tag` | Enforce | MEDIUM | Block 'latest' image tag |
| `require-pod-labels` | Audit | LOW | Standard K8s labels recommended |

## Apply

```bash
kubectl apply -f 06-security/policies/
kubectl get clusterpolicy
```
