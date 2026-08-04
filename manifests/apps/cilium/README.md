# Cilium Monitoring

ServiceMonitors, PrometheusRules, and Grafana dashboards for Cilium CNI and Hubble.

## Components

| File                              | Description                        |
|-----------------------------------|------------------------------------|
| `prom-sm-cilium-agent.yaml`       | ServiceMonitor for Cilium agent    |
| `prom-sm-cilium-operator.yaml`    | ServiceMonitor for Cilium operator |
| `prom-sm-hubble.yaml`             | ServiceMonitor for Hubble          |
| `prom-rule-cilium.yaml`           | PrometheusRule alerts              |
| `grafana-db-cilium-agent.yaml`    | Dashboard: Cilium agent            |
| `grafana-db-cilium-operator.yaml` | Dashboard: Cilium operator         |
| `grafana-db-hubble.yaml`          | Dashboard: Hubble overview         |
| `grafana-db-hubble-dns.yaml`      | Dashboard: Hubble DNS              |
| `grafana-db-hubble-l7.yaml`       | Dashboard: Hubble L7               |
| `grafana-db-hubble-network.yaml`  | Dashboard: Hubble network          |
| `mixin`                           | URL reference to cilium-enterprise mixin (not yet implemented) |

## Prerequisites: Enable Cilium Metrics

Metrics must be enabled in the Cilium Helm values:

```yaml
prometheus:
  enabled: true
operator:
  prometheus:
    enabled: true
hubble:
  enabled: true
  metrics:
    enableOpenMetrics: true
    enabled:
      - dns
      - drop
      - tcp
      - flow
      - port-distribution
      - icmp
      - httpV2:exemplars=true
      - labelsContext=source_ip
      - source_namespace
      - source_workload
      - destination_ip
      - destination_namespace
      - destination_workload
      - traffic_direction
```

Or as Helm `--set` flags:

```
hubble.enabled=true
hubble.metrics.enableOpenMetrics=true
hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
```

## Dashboard Sources

| File                              | Source                                                                                                                                                                                          |
|-----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `grafana-db-cilium-agent.yaml`    | [cilium/cilium — cilium-dashboard.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/cilium-agent/dashboards/cilium-dashboard.json)                               |
| `grafana-db-cilium-operator.yaml` | [cilium/cilium — cilium-operator-dashboard.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/cilium-operator/dashboards/cilium-operator-dashboard.json)          |
| `grafana-db-hubble.yaml`          | [cilium/cilium — hubble-dashboard.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/hubble/dashboards/hubble-dashboard.json)                                     |
| `grafana-db-hubble-dns.yaml`      | [cilium/cilium — hubble-dns-namespace.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/hubble/dashboards/hubble-dns-namespace.json)                             |
| `grafana-db-hubble-l7.yaml`       | [cilium/cilium — hubble-l7-http-metrics-by-workload.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/hubble/dashboards/hubble-l7-http-metrics-by-workload.json) |
| `grafana-db-hubble-network.yaml`  | [cilium/cilium — hubble-network-overview-namespace.json](https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/files/hubble/dashboards/hubble-network-overview-namespace.json)   |
| `mixin` (not yet implemented)     | [monitoring.mixins.dev — Cilium Enterprise](https://monitoring.mixins.dev/cilium-enterprise/) — rules and dashboards pending integration |

## References

- [Cilium metrics documentation](https://docs.cilium.io/en/stable/observability/metrics/)
