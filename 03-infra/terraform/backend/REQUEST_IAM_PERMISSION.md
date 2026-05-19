# Request IAM Permission - Terraform Backend

## Context

- Account ID: `758346258990`
- IAM user in use: `github-actions-deployer`
- Terraform target: create S3 bucket for state and DynamoDB table for lock

## Current error

Initially missing create permissions, and after first grant Terraform still needs additional read/manage permissions:

- `s3:GetBucketPolicy`
- `dynamodb:DescribeContinuousBackups`

=> Updated policy file now includes the extra actions required for Terraform provider read/refresh behavior.

## Policy file to attach

Use updated policy JSON at:

- `required-iam-policy.json`

## Suggested admin command (if admin uses AWS CLI)

```bash
aws iam put-user-policy \
  --user-name github-actions-deployer \
  --policy-name TerraformBackendBootstrap \
  --policy-document file://required-iam-policy.json
```

## Verify after permission granted

```bash
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
terraform output
```
