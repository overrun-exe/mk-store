# Observability assets

This folder contains ready-to-apply manifests and values for a full monitoring
and logging stack in Kubernetes.

## Files

- `kube-prometheus-stack-values.yaml`: values for Prometheus + Grafana
- `loki-stack-values.yaml`: values for Loki + Promtail
- `grafana-datasources-configmap.yaml`: Grafana datasources (Prometheus + Loki)
- `grafana-dashboard-configmap.yaml`: application metrics dashboard
- `grafana-logs-dashboard-configmap.yaml`: application logs dashboard
- `mk-store-dashboard.json`: dashboard source file for manual import if needed

## Deploy manually

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f k8s/observability/kube-prometheus-stack-values.yaml

helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  -f k8s/observability/loki-stack-values.yaml

kubectl apply -f k8s/observability/grafana-datasources-configmap.yaml
kubectl apply -f k8s/observability/grafana-dashboard-configmap.yaml
kubectl apply -f k8s/observability/grafana-logs-dashboard-configmap.yaml
```

## CI deployment

Use manual GitLab job `deploy-observability` from `.gitlab-ci.yml`.
It installs Prometheus/Grafana/Loki/Promtail and applies Grafana datasources and
dashboards from this folder.
