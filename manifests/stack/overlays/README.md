# Overlays

Kustomize overlay patches for Day 2 configuration of stack components.

## How to deploy

You do not. This directory carries no `kustomization.yaml`, so the release never renders
it. List it under `resources:` and the build fails with `must build at directory: not a
valid directory`. Copy a file into your own `overlays/` folder instead, and list the copy
under `patches:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full walkthrough.

## Available Overlays

| File                  | Description                          |
|-----------------------|--------------------------------------|
| `metrics-server.yaml` | Metrics Server configuration patch   |

## Day 2 Configuration

Use Kustomize patches in your own overlay to configure:

### Persistent Storage

Add a `storage` spec to Prometheus, Alertmanager, and Grafana instances via PVC-backed PersistentVolumeClaims.

### Resource Requests and Limits

Configure container `resources.requests` and `resources.limits` for:
- Prometheus
- Alertmanager
- Grafana

### High Availability

Configure replicas, PodDisruptionBudgets, and autoscaling for:
- Prometheus, Alertmanager, Grafana (primary concern)
- Kube State Metrics, Prometheus Operator, Grafana Operator, Karma (secondary)

### Service Exposure

Expose the following via Ingress or Gateway API:
- Grafana
- Karma
- Prometheus

### Alert Routing

Create an `AlertmanagerConfig` resource to route alerts to your receivers.

## ArgoCD Sync Waves

Recommended deployment order (see [manifests/apps/argocd/README.md](../../apps/argocd/README.md)):

| Wave | Components |
|------|-----------|
| -5   | prometheus-operator, grafana-operator, grafana PVC, external secretstore |
| -3   | prometheus, external secret for AlertmanagerConfig |
| -2   | AlertmanagerConfig |
| -1   | alertmanager |
| 0    | Everything else |
