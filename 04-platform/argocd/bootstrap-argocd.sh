# ============================================================
# Bootstrap Argo CD len EKS
# ============================================================

# Buoc 1: Cai dat Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Buoc 2: Doi Argo CD server thanh LoadBalancer (de truy cap UI)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Buoc 3: Lay mat khau admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Buoc 4: Lay URL Argo CD UI
kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

# Buoc 5: Login Argo CD CLI
argocd login <ARGOCD_SERVER_URL> --username admin --password <MAT_KHAU>

# Buoc 6: Apply AppProject va Application tu GitOps repo
kubectl apply -f gitops-repo/argocd/projects/retail-store.yaml
kubectl apply -f gitops-repo/argocd/applications/retail-store-dev.yaml

# Buoc 7: Kiem tra trang thai
argocd app list
argocd app get retail-store-dev
