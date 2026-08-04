# CoreDNS Monitoring

ServiceMonitor, PrometheusRule alerts, and Grafana dashboards for CoreDNS.

## Components

| File                         | Description                           |
|------------------------------|---------------------------------------|
| `prom-sm-coredns.yaml`       | ServiceMonitor                        |
| `prom-rule-coredns.yaml`     | PrometheusRule alerts                 |
| `grafana-db-coredns.yaml`    | Grafana dashboard                     |
| `grafana-db-coredns-mixin.yaml` | Grafana dashboard (mixin-based)    |

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-coredns.yaml` | [Grafana.com dashboard 15762](https://grafana.com/grafana/dashboards/15762) |
| `grafana-db-coredns-mixin.yaml` | [monitoring.mixins.dev — CoreDNS](https://monitoring.mixins.dev/coredns/) |

## References

- [CoreDNS metrics](https://coredns.io/plugins/metrics/)
- [monitoring.mixins.dev](https://monitoring.mixins.dev/)
