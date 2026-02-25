# Terraform: Yandex Cloud infrastructure

This stack creates:
- VPC network and subnet
- Managed Kubernetes cluster and node group
- Service accounts and IAM bindings
- S3 buckets in Object Storage (terraform state + static assets)

## Init backend state in S3

1. First-time bootstrap (local state, create S3 bucket):

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform apply -target=yandex_storage_bucket.tfstate
```

2. Copy the backend config:

```bash
cp backend.hcl.example backend.hcl
```

3. Fill bucket name and static keys.

4. Initialize terraform with S3 backend:

```bash
terraform init -backend-config=backend.hcl
```

## Plan/apply

```bash
cp terraform.tfvars.example terraform.tfvars
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Get kubeconfig

After apply, run:

```bash
yc managed-kubernetes cluster get-credentials --id $(terraform output -raw cluster_id) --external --force
```
