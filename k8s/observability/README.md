# Observability assets

This folder contains:
- `mk-store-dashboard.json`: full dashboard for manual import in Grafana
- `grafana-dashboard-configmap.yaml`: dashboard configmap for Grafana sidecar import

## Recommended stack

1. Install `kube-prometheus-stack`
2. Install `loki` + `promtail`
3. Apply the dashboard configmap:

```bash
kubectl apply -f k8s/observability/grafana-dashboard-configmap.yaml
```

Use backend metrics (`/metrics`) and Kubernetes logs to build SLO dashboards.
