# Notes

<https://docs.cilium.io/en/stable/observability/metrics/>

## Enable the metrics

Enable the metrics with this in the helm values file

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

hubble.enabled=true
hubble.metrics.enableOpenMetrics=true
hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
