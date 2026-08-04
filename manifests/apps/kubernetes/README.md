# Kubernetes Control Plane Monitoring

ServiceMonitors, dashboards, and recording rules for the Kubernetes control plane (API server, kubelet, scheduler, controller manager).

## Components

| Directory / File    | Description                                      |
|---------------------|--------------------------------------------------|
| `control-plane/`    | ServiceMonitors for API server, scheduler, kubelet, controller manager |
| `kubernetes-mixin/` | Kubernetes monitoring mixin rules and dashboards |
| `dotdc/`            | Additional Grafana dashboards from dotdc         |

## Prerequisites: Expose Control Plane Metrics

By default, `kube-controller-manager` and `kube-scheduler` bind their metrics to `127.0.0.1`. Prometheus cannot scrape them unless they bind to `0.0.0.0`.

For kubeadm clusters, edit the `kubeadm-config` ConfigMap in `kube-system` to persist the change:

```yaml
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
```

## Kubernetes Metrics References

- [Kubernetes Component SLI Metrics](https://kubernetes.io/docs/reference/instrumentation/slis/)
- [Kubernetes Metrics Reference](https://kubernetes.io/docs/reference/instrumentation/metrics/)
- [Node metrics data](https://kubernetes.io/docs/reference/instrumentation/node-metrics/)
- [CRI Pod and Container Metrics](https://kubernetes.io/docs/reference/instrumentation/cri-pod-container-metrics/)
- [How to monitor kube-controller-manager](https://sysdig.com/blog/how-to-monitor-kube-controller-manager/)
- [kube-prometheus kubelet ServiceMonitor](https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/kubernetesControlPlane-serviceMonitorKubelet.yaml)

## Dashboard Sources

| Directory | Source |
|-----------|--------|
| `dotdc/` | [dotdc/grafana-dashboards-kubernetes](https://github.com/dotdc/grafana-dashboards-kubernetes) — Grafana.com IDs [15757](https://grafana.com/grafana/dashboards/15757), [15758](https://grafana.com/grafana/dashboards/15758), [15759](https://grafana.com/grafana/dashboards/15759), [15760](https://grafana.com/grafana/dashboards/15760), [15761](https://grafana.com/grafana/dashboards/15761) |
| `kubernetes-mixin/` | [monitoring.mixins.dev — Kubernetes](https://monitoring.mixins.dev/kubernetes/) — kubernetes-mixin v1.4.2 |
