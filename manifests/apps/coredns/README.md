# CoreDNS Monitoring

PrometheusRule alerts and Grafana dashboards for CoreDNS, plus one scrape component per
platform.

## Files

| File                         | Description                           |
|------------------------------|---------------------------------------|
| `prom-rule-coredns.yaml`     | PrometheusRule alerts                 |
| `grafana-db-coredns.yaml`    | Grafana dashboard                     |
| `grafana-db-coredns-mixin.yaml` | Grafana dashboard (mixin-based)    |

## Scrape components

How CoreDNS runs, and therefore how you scrape it, depends on the platform. Add exactly
one of these to `components:`. They all produce `job="kube-dns"`, so the alerts and
dashboards above match in every case.

| Component | Platform | Mechanism |
|---|---|---|
| [`kubeadm`](kubeadm/README.md) | kubeadm clusters | ServiceMonitor on the `kube-dns` Service |
| [`eks-auto-mode`](eks-auto-mode/README.md) | EKS Auto Mode | ServiceMonitor on a node-exporter sidecar |
| [`ionos`](ionos/README.md) | IONOS Managed Kubernetes | PodMonitor on the CoreDNS pods |

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-coredns.yaml` | [Grafana.com dashboard 15762](https://grafana.com/grafana/dashboards/15762) |
| `grafana-db-coredns-mixin.yaml` | [monitoring.mixins.dev, CoreDNS](https://monitoring.mixins.dev/coredns/) |

## References

- [CoreDNS metrics](https://coredns.io/plugins/metrics/)
- [monitoring.mixins.dev](https://monitoring.mixins.dev/)
