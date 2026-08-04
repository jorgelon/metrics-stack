# NATS JetStream Monitoring

Custom Resource State metrics, ServiceMonitor, and Grafana dashboard for NATS JetStream.

## Components

| File                               | Description                                      |
|------------------------------------|--------------------------------------------------|
| `service-monitor.yaml`             | ServiceMonitor                                   |
| `jetstream-state-metrics-cm.yaml`  | ConfigMap with kube-state-metrics CRS config     |
| `jetstream-state-metrics-dashboard.yaml` | Grafana dashboard                          |

## References

- [NATS JetStream](https://docs.nats.io/nats-concepts/jetstream)
- [kube-state-metrics Custom Resource State](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md)
