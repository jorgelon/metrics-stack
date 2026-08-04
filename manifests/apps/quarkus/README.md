# Quarkus Monitoring

Grafana dashboard for Quarkus applications.

## Components

| File                      | Description                   |
|---------------------------|-------------------------------|
| `grafana-db-quarkus.yaml` | Grafana dashboard for Quarkus |

## Prerequisites

This directory does not include a ServiceMonitor or PodMonitor — Quarkus applications cannot be standardized across deployments. Create a ServiceMonitor or PodMonitor manually per application, outside this repository.

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-quarkus.yaml` | [Grafana.com dashboard 14370](https://grafana.com/grafana/dashboards/14370) |

## References

- [Quarkus — Micrometer metrics](https://quarkus.io/guides/micrometer)
- [Quarkus — SmallRye metrics](https://quarkus.io/guides/smallrye-metrics)
