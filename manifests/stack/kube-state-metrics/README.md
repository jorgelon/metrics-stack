# Kube State Metrics

Hand-crafted manifests for kube-state-metrics — generates Prometheus metrics from Kubernetes object state.

## Components

| File                            | Description                             |
|---------------------------------|-----------------------------------------|
| `k8s-deploy-kube-state-metrics.yaml` | Deployment                         |
| `k8s-sa-kube-state-metrics.yaml`     | ServiceAccount                     |
| `k8s-cr-kube-state-metrics.yaml`     | ClusterRole with resource permissions |
| `k8s-crb-kube-state-metrics.yaml`    | ClusterRoleBinding                 |
| `k8s-svc-kube-state-metrics.yaml`    | Service                            |
| `prom-sm-kube-state-metrics.yaml`    | ServiceMonitor                     |
| `prom-rule-kube-state-metrics.yaml`  | PrometheusRule alerts              |

## Extending RBAC for Custom Resources

To add metrics for custom resources (e.g. Gateway API), add the relevant app directory to your root `components:` instead of `resources:`. See [manifests/apps/gateway-api/](../../apps/gateway-api/), a kustomize component that patches this ClusterRole and Deployment — so it composes with the whole `stack/` kustomization instead of replacing this directory.

## References

- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [Standard example manifests](https://github.com/kubernetes/kube-state-metrics/tree/main/examples/standard)
- [Custom Resource State Metrics](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md)
