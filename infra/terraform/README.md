# Terraform: Yandex Cloud infrastructure

This stack creates:
- VPC network and subnet
- Managed Kubernetes cluster and node group
- Service accounts and IAM bindings
- Optional assets bucket in Object Storage

## Init backend state in S3

1. Create S3 bucket for terraform state manually (one-time):

```bash
yc storage bucket create --name <tfstate-bucket-name>
```

2. Copy the backend config:

```bash
cp backend.hcl.example backend.hcl
```

3. Fill bucket name and static keys.
   - use a real bucket name instead of `replace-with-tfstate-bucket`
   - keep endpoint as full URL (`https://storage.yandexcloud.net`)
   - `assets_bucket_name` is used for static files upload
   - set `create_assets_bucket = true` only if you want terraform to create assets bucket
   - set `kubernetes_version = ""` to use current default version for selected release channel

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
