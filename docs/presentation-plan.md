# Presentation plan (5-10 minutes)

## 1. Goal and architecture (1 min)
- what mk-store does
- target architecture: GitLab -> Nexus/SonarQube -> Yandex Cloud K8s

## 2. CI/CD flow (2 min)
- explain `.gitlab-ci.yml` stages
- show versioning strategy for image, binary, and chart
- show where artifacts are stored in Nexus

## 3. Infrastructure as code (2 min)
- review `infra/terraform` modules
- explain S3 backend state and why it is used
- show cluster and buckets created by Terraform

## 4. Kubernetes deployment (2 min)
- show Helm chart structure
- show ingress, services, probes, secrets
- show optional raw manifests in `k8s/base`

## 5. Observability and operations (1-2 min)
- backend metrics endpoint and ServiceMonitor
- logging strategy and dashboard expectations
- rollout/rollback approach with Helm

## 6. Cost optimization decisions (1 min)
- preemptible nodes
- minimal resource requests/limits
- clean-up procedure after project completion

## 7. Demo scenario (1-2 min)
- run pipeline
- verify app endpoint
- verify metrics endpoint and pod health
