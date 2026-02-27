# mk-store CI/CD diploma project

Full CI/CD cycle for mk-store in Yandex Cloud:
- source code in GitLab
- build artifacts and images in GitLab Container/Package Registry
- quality gate in SonarQube
- infrastructure in Terraform (IaC)
- deployment to Kubernetes using Helm

## Services

- GitLab: https://gitlab.praktikum-services.ru/std-036-33/mk-store
- SonarQube: https://sonarqube.praktikum-services.ru/

## Repository structure

```text
.
├── .gitlab-ci.yml
├── backend/
│   ├── Dockerfile
│   └── ... Go API
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ... Vue app
├── helm/
│   └── mk-store/                 # Helm chart for app deployment
├── k8s/
│   ├── base/                     # Raw Kubernetes manifests
│   └── observability/            # Grafana dashboard assets
├── infra/
│   └── terraform/                # Yandex Cloud IaC + S3 state setup
├── docs/
│   └── presentation-plan.md
└── sonar-project.properties
```

## Git flow

`main` is production-ready.

Branch model:
- `feature/*` for implementation
- merge request into `main`
- release by tag `vMAJOR.MINOR.PATCH`

## Local development

### Backend

```bash
cd backend
go test ./...
go run ./cmd/api
```

### Frontend

```bash
cd frontend
npm ci
VUE_APP_API_URL=http://localhost:8081 VUE_APP_PUBLIC_PATH=/ npm run serve
```

## Docker images

- Backend image builds a static Go binary and runs it in Alpine.
- Frontend image builds Vue static files and serves them with Nginx.

Local build examples:

```bash
docker build -f backend/Dockerfile -t mk-store/backend:local backend
docker build -f frontend/Dockerfile -t mk-store/frontend:local frontend
```

## CI pipeline

Pipeline is defined in `.gitlab-ci.yml` and contains stages:
- `test`: Go tests, frontend build check, SonarQube scan
- `build`: build backend binary
- `publish`: publish binary, Docker images, Helm chart, static assets
- `deploy`: terraform plan/apply and Helm deploy to Kubernetes

### Required GitLab CI/CD variables

GitLab Registry / deploy:
- `KUBE_URL` (recommended, Kubernetes API endpoint, e.g. `https://<ip-or-fqdn>`)
- `KUBE_TOKEN` (recommended, bearer token for deploy user/service account)
- `KUBE_CONFIG_B64` (optional fallback: base64 kubeconfig without local `yc` exec plugin)
- `APP_HOST` (for ingress host)
- `TLS_SECRET_NAME` (TLS secret)
- `ENABLE_IP_ACCESS` (`true`/`false`, creates additional hostless ingress for access by external IP)
- `REGISTRY_PULL_USER` (GitLab Deploy Token username, recommended)
- `REGISTRY_PULL_PASSWORD` (GitLab Deploy Token password/token, recommended)
- `APP_JWT_SECRET` (optional app secret)
- `ENABLE_SERVICE_MONITOR` (`true`/`false`)

SonarQube:
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Terraform / Object Storage:
- `TF_BACKEND_CONFIG` (content of `infra/terraform/backend.hcl`; use GitLab `File` variable or multiline text)
- `S3_ENDPOINT` (for Yandex Object Storage, usually `https://storage.yandexcloud.net`)
- `ASSETS_BUCKET`
- `AWS_ACCESS_KEY_ID` (optional if `TF_VAR_storage_access_key` is set)
- `AWS_SECRET_ACCESS_KEY` (optional if `TF_VAR_storage_secret_key` is set)

Terraform provider vars (recommended in CI as protected/masked):
- `TF_VAR_yc_token`
- `TF_VAR_cloud_id`
- `TF_VAR_folder_id`
- `TF_VAR_ssh_public_key`
- `TF_VAR_assets_bucket_name`
- `TF_VAR_create_assets_bucket` (`false` by default; set `true` only if terraform should create assets bucket)
- `TF_VAR_storage_access_key`
- `TF_VAR_storage_secret_key`

## Infrastructure deployment (Terraform)

Terraform code is in `infra/terraform`.

### 1. Bootstrap state bucket (first run only)

On a clean environment create the state bucket manually once:

```bash
cd infra/terraform
yc storage bucket create --name <tfstate-bucket-name>
```

After bucket creation, switch to S3 backend.

### 2. Prepare backend config

```bash
cp backend.hcl.example backend.hcl
```

Fill real values in both files.
Do not keep placeholders (for example `replace-with-tfstate-bucket`), and keep S3 endpoint as `https://storage.yandexcloud.net`.

### 3. Initialize, validate, apply with remote state

```bash
terraform init -backend-config=backend.hcl
terraform fmt
terraform validate
terraform plan
terraform apply
```

### 4. Get kubeconfig

```bash
yc managed-kubernetes cluster get-credentials --id $(terraform output -raw cluster_id) --external --force
```

## Application deployment

### Option A: via Helm in CI (recommended)

Run manual GitLab job `deploy-production` on `main` or tag.
If `ENABLE_IP_ACCESS=true`, app is also reachable by external ingress IP over HTTP.

### Option B: manually from local machine

```bash
helm upgrade --install mk-store ./helm/mk-store \
  --namespace mk-store \
  --create-namespace \
  --set backend.image.repository=<backend-image-repo> \
  --set backend.image.tag=<tag> \
  --set frontend.image.repository=<frontend-image-repo> \
  --set frontend.image.tag=<tag> \
  --set ingress.host=<your-domain>
```

## Kubernetes manifests and Helm

- Raw manifests: `k8s/base`
- Helm chart: `helm/mk-store`
- production values example: `helm/mk-store/values.prod.yaml`

Helm chart is packaged and versioned in CI, then uploaded to GitLab Package Registry.

## Artifact versioning rules

- Docker image tags (GitLab Container Registry):
  - release tag: `vX.Y.Z` (same value)
  - branch build: `CI_COMMIT_SHORT_SHA`
- Backend binary (GitLab Generic Package Registry):
  - `vX.Y.Z` for releases
  - `0.1.<pipeline_iid>` for non-tag builds
- Helm chart (GitLab Generic Package Registry):
  - release tag: semantic version from git tag
  - branch build: `0.1.<pipeline_iid>`

## Static files in S3

Static file upload job: `upload-static-assets`.

Example uploaded file:
- `frontend/src/assets/logo.png` -> `s3://$ASSETS_BUCKET/logo.png`

## Secrets handling

No production secrets are stored in git.

- sensitive values are provided via GitLab protected variables
- runtime Kubernetes secrets are created during deploy job
- `k8s/base/secrets.example.yaml` contains placeholders only

## Monitoring and logging

- Backend exposes Prometheus metrics on `/metrics`
- `ServiceMonitor` templates are included in Helm and raw manifests
- app logs go to `stdout`; can be collected by your cluster log stack (for example, Loki + Promtail)
- recommended dashboard: Grafana (request rate, p95 latency, 5xx ratio, pod health)
- dashboard assets are in `k8s/observability`

## Rules for infrastructure changes

- all infra changes go through merge requests
- no manual drift in cloud console for managed resources
- required checks before merge:
  - `terraform fmt`
  - `terraform validate`
  - `terraform plan` review
- every infra change must update docs when behavior changes

## Release cycle

1. Develop in `feature/*`
2. Merge request to `main`
3. CI runs tests and build
4. Create release tag `vX.Y.Z`
5. CI publishes immutable artifacts to GitLab Registry
6. Run `deploy-production` for rollout

## Presentation plan

See `docs/presentation-plan.md`.

## Submission note

If you have extra repositories (infra-only, observability, etc.), include links here in this README so one GitLab URL is enough for review.
