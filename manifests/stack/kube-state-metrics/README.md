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

To add metrics for custom resources (e.g. Gateway API), use the overlay in the relevant app directory. See [manifests/apps/gateway-api/overlay/](../../apps/gateway-api/overlay/) for an example that patches the ClusterRole and Deployment.

## References

- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [Standard example manifests](https://github.com/kubernetes/kube-state-metrics/tree/main/examples/standard)
- [Custom Resource State Metrics](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md)
