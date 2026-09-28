# CoreDNS Monitoring

PrometheusRule alerts and Grafana dashboards for CoreDNS, plus one scrape component per
platform.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. It ships no scrape target. Add exactly one platform directory next to it.

```yaml
resources:
  - <release>/apps/coredns
```

## Files

| File                         | Description                           |
|------------------------------|---------------------------------------|
| `prom-rule-coredns.yaml`     | PrometheusRule alerts                 |
| `grafana-db-coredns.yaml`    | Grafana dashboard                     |
| `grafana-db-coredns-mixin.yaml` | Grafana dashboard (mixin-based)    |

## Scrape targets

How CoreDNS runs, and therefore how you scrape it, depends on the platform. Add exactly
one of these. They all produce `job="kube-dns"`, so the alerts and dashboards above match
in every case. The "Add under" column gives the kustomization field. Only
`eks-auto-mode` is a kustomize component, because it is the only one that patches a
resource it does not own.

| Directory | Platform | Mechanism | Add under |
|---|---|---|---|
| [`kubeadm`](kubeadm/README.md) | kubeadm clusters | ServiceMonitor on the `kube-dns` Service | `resources:` |
| [`eks-auto-mode`](eks-auto-mode/README.md) | EKS Auto Mode | ServiceMonitor on a node-exporter sidecar | `components:` |
| [`ionos`](ionos/README.md) | IONOS Managed Kubernetes | PodMonitor on the CoreDNS pods | `resources:` |

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-coredns.yaml` | [Grafana.com dashboard 15762](https://grafana.com/grafana/dashboards/15762) |
| `grafana-db-coredns-mixin.yaml` | [monitoring.mixins.dev, CoreDNS](https://monitoring.mixins.dev/coredns/) |

## References

- [CoreDNS metrics](https://coredns.io/plugins/metrics/)
- [monitoring.mixins.dev](https://monitoring.mixins.dev/)
