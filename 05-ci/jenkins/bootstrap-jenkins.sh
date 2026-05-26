# Bootstrap Jenkins on EKS

helm repo add jenkins https://charts.jenkins.io
helm repo update

# Install Jenkins with LoadBalancer (may not work due to AWS NLB restriction)
# Use port-forward as fallback
kubectl create namespace jenkins

helm install jenkins jenkins/jenkins -n jenkins \
  --set controller.serviceType=LoadBalancer \
  --set controller.admin.password=devsecops2026 \
  --set persistence.enabled=false \
  --set controller.resources.requests.cpu=250m \
  --set controller.resources.requests.memory=512Mi

# Wait for pod
kubectl wait --for=condition=Ready pod/jenkins-0 -n jenkins --timeout=300s

# Access via port-forward if LoadBalancer pending
kubectl port-forward -n jenkins jenkins-0 8080:8080

# URL: http://localhost:8080
# Username: admin
# Password: devsecops2026
