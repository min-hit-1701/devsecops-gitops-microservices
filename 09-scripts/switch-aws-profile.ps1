param(
  [string]$Profile = "uit-devsecops"
)

$env:AWS_PROFILE = $Profile
Write-Host "AWS_PROFILE set to '$Profile'"
aws sts get-caller-identity
