# Loki Integration

Grafana datasource and dashboards for Loki log aggregation.

## Components

| File / Directory      | Description                                        |
|-----------------------|----------------------------------------------------|
| `grafana-ds-loki.yaml`| Grafana datasource pointing to the Loki instance   |
| `dashboards/`         | Loki Grafana dashboards                            |
| `loki-infra/`         | Loki infrastructure monitoring dashboards          |

## Prerequisites

Loki must be deployed at `http://loki.loki.svc.cluster.local:3100` (namespace `loki`, service `loki`). The datasource is pre-configured with that URL.

The infrastructure dashboards are sourced from the [loki-mixin-compiled](https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled) project.

## Dashboard Sources

| Directory | Source |
|-----------|--------|
| `dashboards/` | Grafana.com: [13639](https://grafana.com/grafana/dashboards/13639), [15141](https://grafana.com/grafana/dashboards/15141), [16970](https://grafana.com/grafana/dashboards/16970) |
| `loki-infra/` | [grafana/loki — loki-mixin-compiled](https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled) — Grafana.com [17781](https://grafana.com/grafana/dashboards/17781) |

## References

- [Grafana Loki](https://grafana.com/oss/loki/)
- [loki-mixin-compiled](https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled)
