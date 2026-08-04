# Core Cluster Monitoring

Essential Kubernetes cluster monitoring rules — nodes, volumes, and recording rules.

## Components

| File                           | Description                                          |
|--------------------------------|------------------------------------------------------|
| `prom-rule-nodes.yaml`         | PrometheusRule alerts for node health                |
| `prom-rule-volumes.yaml`       | PrometheusRule alerts for PVC/volume usage           |
| `prom-rule-recording-k8s.yaml` | Recording rules for Kubernetes dashboards            |

## Kubernetes Metrics References

- [Kubernetes Component SLI Metrics](https://kubernetes.io/docs/reference/instrumentation/slis/)
- [Kubernetes Metrics Reference](https://kubernetes.io/docs/reference/instrumentation/metrics/)
- [CRI Pod and Container Metrics](https://kubernetes.io/docs/reference/instrumentation/cri-pod-container-metrics/)

## Notes on Namespace Selectors

- An **empty** label selector (`{}`) matches all namespaces.
- A **null** label selector (default) matches only the current namespace.
