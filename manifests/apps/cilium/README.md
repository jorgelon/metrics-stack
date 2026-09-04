# Cilium Monitoring

ServiceMonitors, PrometheusRules, and Grafana dashboards for Cilium CNI and Hubble.

## Components

| File                              | Description                                       |
|-----------------------------------|---------------------------------------------------|
| `prom-sm-cilium-agent.yaml`       | ServiceMonitor for Cilium agent                   |
| `prom-sm-cilium-operator.yaml`    | ServiceMonitor for Cilium operator                |
| `prom-sm-hubble.yaml`             | ServiceMonitor for Hubble                         |
| `prom-sm-hubble-relay.yaml`       | ServiceMonitor for Hubble Relay                   |
| `prom-rule-cilium.yaml`           | PrometheusRule alerts (generated)                 |
| `generate-prometheus-rule.sh`     | Regenerates `prom-rule-cilium.yaml` from upstream |
| `grafana-db-cilium-agent.yaml`    | Dashboard: Cilium agent                           |
| `grafana-db-cilium-operator.yaml` | Dashboard: Cilium operator                        |
| `grafana-db-hubble.yaml`          | Dashboard: Hubble overview                        |
| `grafana-db-hubble-dns.yaml`      | Dashboard: Hubble DNS                             |
| `grafana-db-hubble-l7.yaml`       | Dashboard: Hubble L7                              |
| `grafana-db-hubble-network.yaml`  | Dashboard: Hubble network                         |

## Alert Rules

`prom-rule-cilium.yaml` is generated — edit the script, not the YAML:

```bash
./generate-prometheus-rule.sh
```

Cilium ships **no official alerting rules** — the upstream project provides only
dashboards, ServiceMonitors and an example Prometheus stack whose `rule_files`
glob is never populated. Community rulesets are therefore the only option.

The single group `cilium-awesome` comes from
[awesome-prometheus-alerts — cilium/embedded-exporter.yml](https://github.com/samber/awesome-prometheus-alerts/blob/master/dist/rules/cilium/embedded-exporter.yml).

### Why not the cilium-enterprise mixin

The [cilium-enterprise mixin](https://github.com/monitoring-mixins/website/blob/master/assets/cilium-enterprise/alerts.yaml)
targets Isovalent's commercial build and is intentionally not generated. Every
one of its alerts either duplicates a `cilium-awesome` alert under a different
name, is a narrower subset of one, or is misformulated — including one that
applies `rate()` to a gauge and so can never fire.

### Threshold caveat

Most awesome alerts trigger on `rate(...) > 0.05`, i.e. roughly one event per 20s
sustained for the `for:` window. For rare-but-serious failures (BPF map writes,
endpoint regeneration, policy import, conntrack GC) a small burst passes
silently. Lower those thresholds toward `0` if you would rather catch single
failures.

### Upstream selectors corrected by the script

Verified against Cilium v1.19.4; re-check when upgrading Cilium.

| Alert(s)                                                                | Upstream selector                             | Problem                                                                                                                     |
|-------------------------------------------------------------------------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| `CiliumAgentPolicyImportErrors`                                         | `cilium_policy_change_total{outcome="fail"}`  | The label value is `failure`. Other metrics do use `fail`, so the fix is per-metric                                         |
| `CiliumAgentEndpointUpdateFailure`, `CiliumAgentKubernetesClientErrors` | `endpoint="endpoint"` / `endpoint!="metrics"` | `endpoint` is the ServiceMonitor port name (always `metrics`), not a Cilium label, so these selectors excluded every series |

### Alerts inactive without extra features

These emit no series on a default install and simply never fire: IPAM alerts
(`cilium_operator_ipam_*`, ENI/Azure IPAM only), ClusterMesh and KVStoreMesh
alerts, and `CiliumHubbleHighDnsErrorRate` (needs the Hubble `dns` metric
enabled).

## Prerequisites: Enable Cilium Metrics

Metrics must be enabled in the Cilium Helm values:

```yaml
prometheus:              # cilium-agent, port 9962
  enabled: true
  metricsService: true   # required: see below
operator:
  prometheus:            # cilium-operator, port 9963 (chart default: true)
    enabled: true
    metricsService: true # required: see below
envoy:
  prometheus:            # cilium-envoy, port 9964 (chart default: true)
    enabled: true
hubble:
  enabled: true
  relay:
    enabled: true
    prometheus:          # hubble-relay, port 9966
      enabled: true
  metrics:               # hubble (agent), port 9965
    enabled:
      - dns
      - drop
      - tcp
      - flow
      - port-distribution
      - icmp
      - httpV2:labelsContext=source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction
```

### Metrics disabled by default

Some Cilium metrics are disabled by default. Enable if desired

```yaml
prometheus:
  enabled: true
  metrics:
    - +cilium_bpf_syscall_duration_seconds  # agent dashboard bpf
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
| `awesome` (not yet implemented)   | <https://samber.github.io/awesome-prometheus-alerts/rules/network-and-security/cilium/>                                                                                                         |

## References

- [Cilium metrics documentation](https://docs.cilium.io/en/stable/observability/metrics/)
