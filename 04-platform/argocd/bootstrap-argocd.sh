# ============================================================
# Bootstrap Argo CD on EKS
# ============================================================

# Step 1: Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 2: Change Argo CD server to LoadBalancer (to access UI)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Step 3: Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Step 4: Get Argo CD UI URL
kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

# Step 5: Login Argo CD CLI
argocd login <ARGOCD_SERVER_URL> --username admin --password <MAT_KHAU>

# Step 6: Apply AppProject and Application from GitOps repo
kubectl apply -f gitops-repo/argocd/projects/retail-store.yaml
kubectl apply -f gitops-repo/argocd/applications/retail-store-dev.yaml

# Step 7: Check status
argocd app list
argocd app get retail-store-dev
