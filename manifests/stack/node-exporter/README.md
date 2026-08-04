# Node Exporter

Hand-crafted manifests for Prometheus Node Exporter — collects host-level hardware and OS metrics.

## Components

| File                               | Description                     |
|------------------------------------|---------------------------------|
| `k8s-ds-node-exporter.yaml`        | DaemonSet (runs on every node)  |
| `k8s-sa-node-exporter.yaml`        | ServiceAccount                  |
| `k8s-secret-node-exporter-sa-token.yaml` | ServiceAccount token      |
| `k8s-cr-node-exporter.yaml`        | ClusterRole                     |
| `k8s-crb-node-exporter.yaml`       | ClusterRoleBinding              |
| `k8s-svc-node-exporter.yaml`       | Service                         |
| `prom-sm-node-exporter.yaml`       | ServiceMonitor                  |
| `prom-rule-node-exporter.yaml`     | PrometheusRule alerts           |

## References

- [Prometheus Node Exporter](https://github.com/prometheus/node_exporter)
- [Node Exporter metrics](https://kubernetes.io/docs/reference/instrumentation/node-metrics/)
