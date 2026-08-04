# etcd Monitoring

ServiceMonitor and Grafana dashboard for etcd.

## Components

| File                       | Description                                     |
|----------------------------|-------------------------------------------------|
| `prom-sm-etcd.yaml`        | ServiceMonitor                                  |
| `k8s-svc-etcd-metrics.yaml`| Service exposing etcd metrics endpoint          |
| `grafana-db-etcd.yaml`     | Grafana dashboard (official, slightly modified) |

## Prerequisites

etcd must expose its metrics on `0.0.0.0` (not `127.0.0.1`). If etcd is bound to localhost, the ServiceMonitor cannot scrape it.

For kubeadm clusters, you can override the bind address in the `kubeadm-config` ConfigMap in `kube-system`:

```yaml
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
```

If etcd cannot be reconfigured, scrape it via an alternative means (e.g. a sidecar or push gateway) and use the dashboard directly.

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-etcd.yaml` | [etcd-io/website — grafana.json](https://github.com/etcd-io/website/blob/main/content/en/docs/v3.6/op-guide/grafana.json) (official, slightly modified: unwrapped JSON structure and added missing root `title` field for Grafana Operator compatibility) |

## References

- [How to monitor kube-controller-manager](https://sysdig.com/blog/how-to-monitor-kube-controller-manager/)
- [kube-prometheus kubelet ServiceMonitor example](https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/refs/heads/main/manifests/kubernetesControlPlane-serviceMonitorKubelet.yaml)
