# Terraform Backend

Objective:
- S3 bucket for state
- DynamoDB for locking

## Files in This Directory

- `versions.tf`
- `providers.tf`
- `variables.tf`
- `main.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Quick Start

1. Create the actual variables file:
   - copy `terraform.tfvars.example` to `terraform.tfvars`
2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

3. After applying, retrieve the output:

```bash
terraform output backend_tf_snippet
```

Use this output to configure the `s3` backend for other Terraform modules.

## Notes

- Do not commit credentials.
- Use profiles or roles.
- Set up budget alarms before provisioning.
