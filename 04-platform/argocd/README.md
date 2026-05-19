# Argo CD

## Bootstrap

```bash
# 1. Cai dat Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Expose Argo CD UI qua LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 3. Lay mat khau admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# 4. URL Argo CD UI
kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

## Deploy GitOps Apps

```bash
kubectl apply -f gitops-repo/argocd/projects/retail-store.yaml
kubectl apply -f gitops-repo/argocd/applications/retail-store-dev.yaml
```

## Rollback

Argo CD tu dong sync tu Git. Rollback = git revert:

```bash
cd gitops-repo
git revert <commit-hash>
git push origin HEAD
```
