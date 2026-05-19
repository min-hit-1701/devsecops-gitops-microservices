Write-Host "Installing required tools with winget..."

$tools = @(
  @{ id = "Hashicorp.Terraform"; name = "Terraform" },
  @{ id = "Kubernetes.kubectl"; name = "kubectl" },
  @{ id = "Helm.Helm"; name = "Helm" },
  @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" }
)

foreach ($tool in $tools) {
  Write-Host "Installing $($tool.name)..."
  winget install --id $tool.id --exact --accept-source-agreements --accept-package-agreements
}

Write-Host "Done. Please restart terminal after installation."
