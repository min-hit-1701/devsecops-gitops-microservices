# Argo CD

## Bootstrap

```bash
# 1. Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Expose Argo CD UI via LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 3. Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# 4. Argo CD UI URL
kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

## Deploy GitOps Apps

```bash
kubectl apply -f gitops-repo/argocd/projects/retail-store.yaml
kubectl apply -f gitops-repo/argocd/applications/retail-store-dev.yaml
```

## Rollback

Argo CD auto-syncs from Git. Rollback = git revert:

```bash
cd gitops-repo
git revert <commit-hash>
git push origin HEAD
```
