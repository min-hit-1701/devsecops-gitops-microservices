param(
  [string]$AdminProfile = "admin",
  [string]$ProjectUserName = "uit-devsecops-gitops-deployer",
  [string]$ProjectProfile = "uit-devsecops",
  [string]$Region = "ap-southeast-1",
  [string]$PolicyName = "TerraformBackendBootstrap",
  [string]$PolicyFilePath = "D:\\DACN\\do-an-devsecops-gitops\\03-infra\\terraform\\backend\\required-iam-policy.json"
)

$ErrorActionPreference = "Stop"

Write-Host "[1/6] Checking admin identity from profile '$AdminProfile'..."
aws sts get-caller-identity --profile $AdminProfile | Out-Null

Write-Host "[2/6] Creating IAM user '$ProjectUserName' (skip if exists)..."
try {
  aws iam create-user --user-name $ProjectUserName --profile $AdminProfile | Out-Null
  Write-Host "User created."
}
catch {
  if ($_.Exception.Message -match "EntityAlreadyExists") {
    Write-Host "User already exists."
  }
  else {
    throw
  }
}

Write-Host "[3/6] Attaching inline policy '$PolicyName' from file..."
aws iam put-user-policy `
  --user-name $ProjectUserName `
  --policy-name $PolicyName `
  --policy-document "file://$PolicyFilePath" `
  --profile $AdminProfile | Out-Null

Write-Host "[4/6] Creating access key for '$ProjectUserName'..."
$accessKeyJson = aws iam create-access-key --user-name $ProjectUserName --profile $AdminProfile
$accessKey = $accessKeyJson | ConvertFrom-Json

if (-not $accessKey.AccessKey.AccessKeyId) {
  throw "Cannot create access key. Check IAM key limit or permissions."
}

$accessKeyId = $accessKey.AccessKey.AccessKeyId
$secretAccessKey = $accessKey.AccessKey.SecretAccessKey

Write-Host "[5/6] Configuring AWS CLI profile '$ProjectProfile'..."
aws configure set aws_access_key_id $accessKeyId --profile $ProjectProfile
aws configure set aws_secret_access_key $secretAccessKey --profile $ProjectProfile
aws configure set region $Region --profile $ProjectProfile
aws configure set output json --profile $ProjectProfile

Write-Host "[6/6] Verifying new profile..."
aws sts get-caller-identity --profile $ProjectProfile

Write-Host ""
Write-Host "Done. Use this profile in terminal:"
Write-Host "  PowerShell: `$env:AWS_PROFILE='$ProjectProfile'"
Write-Host "  Bash: export AWS_PROFILE=$ProjectProfile"
