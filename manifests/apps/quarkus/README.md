# Quarkus Monitoring

Grafana dashboard for Quarkus applications.

## Files

| File                      | Description                   |
|---------------------------|-------------------------------|
| `grafana-db-quarkus.yaml` | Grafana dashboard for Quarkus |

## Prerequisites

The release ships no ServiceMonitor or PodMonitor here. Quarkus applications do not share
a layout, so no single scrape target fits them all. Write one per application in your own
source.

[`examples/prom-sm-quarkus.yaml`](examples/README.md) is a starting point. It is an
example, not a component: copy the file, replace every `changeme`, and list the copy under
`resources:`.

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-quarkus.yaml` | [Grafana.com dashboard 14370](https://grafana.com/grafana/dashboards/14370) |

## References

- [Quarkus, Micrometer metrics](https://quarkus.io/guides/micrometer)
- [Quarkus, SmallRye metrics](https://quarkus.io/guides/smallrye-metrics)
