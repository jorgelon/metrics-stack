# Alertmanager

Alertmanager instance managed by the Prometheus Operator.

## Components

| File                       | Description                            |
|----------------------------|----------------------------------------|
| `prom-am-instance.yaml`    | Alertmanager CRD instance              |
| `k8s-sa-alertmanager.yaml` | ServiceAccount                         |

## Configuration

Alertmanager has no built-in routing config. Create an `AlertmanagerConfig` resource in the `monitoring` namespace to route alerts to your preferred receivers (PagerDuty, Slack, email, etc.).

## ArgoCD Sync Wave

Deploy at wave `-1` — after Prometheus Operator (wave -5) and Prometheus (wave -3).

See [manifests/apps/argocd/README.md](../../apps/argocd/README.md) for full wave recommendations.

## References

- [Prometheus Operator — Alertmanager](https://prometheus-operator.dev/docs/operator/alertmanager/)
- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
