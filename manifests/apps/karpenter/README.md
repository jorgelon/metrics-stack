# Karpenter Monitoring

ServiceMonitor, PrometheusRule alerts, and Grafana dashboards for Karpenter node autoscaler.

## Components

| File                                           | Description                        |
|------------------------------------------------|------------------------------------|
| `prom-sm-karpenter.yaml`                       | ServiceMonitor                     |
| `prom-rule.yaml`                               | PrometheusRule alerts              |
| `grafana-db-karpenter-controllers.yaml`        | Dashboard: controllers             |
| `grafana-db-karpenter-controllers-allocation.yaml` | Dashboard: allocation          |
| `grafana-db-karpenter-capacity-dashboard.yaml` | Dashboard: capacity                |
| `grafana-db-karpenter-performance-dashboard.yaml`| Dashboard: performance           |

## Dashboard Sources

All dashboards sourced from the official [aws/karpenter-provider-aws](https://github.com/aws/karpenter-provider-aws) repository (v1.5):

| File | Source |
|------|--------|
| `grafana-db-karpenter-controllers.yaml` | [karpenter-controllers.json](https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.5/getting-started/getting-started-with-karpenter/karpenter-controllers.json) |
| `grafana-db-karpenter-controllers-allocation.yaml` | [karpenter-controllers-allocation.json](https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.5/getting-started/getting-started-with-karpenter/karpenter-controllers-allocation.json) |
| `grafana-db-karpenter-capacity-dashboard.yaml` | [karpenter-capacity-dashboard.json](https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.5/getting-started/getting-started-with-karpenter/karpenter-capacity-dashboard.json) |
| `grafana-db-karpenter-performance-dashboard.yaml` | [karpenter-performance-dashboard.json](https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.5/getting-started/getting-started-with-karpenter/karpenter-performance-dashboard.json) |

## References

- [Karpenter](https://karpenter.sh/)
- [Karpenter metrics](https://karpenter.sh/docs/reference/metrics/)
