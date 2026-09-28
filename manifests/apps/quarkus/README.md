# Quarkus Monitoring

Grafana dashboard for Quarkus applications.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. It ships the dashboard only. Copy the example to add a scrape target.

```yaml
resources:
  - <release>/apps/quarkus
```

## Files

| File                      | Description                   |
|---------------------------|-------------------------------|
| `grafana-db-quarkus.yaml` | Grafana dashboard for Quarkus |

## Prerequisites

The release ships no ServiceMonitor or PodMonitor here. Quarkus applications do not share
a layout, so no single scrape target fits them all. Write one per application in your own
source.

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy the file into your `instance/`
folder and list the copy under `resources:`.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `prom-sm-quarkus.yaml` | Scrapes one Quarkus application | `instance/` | `resources:` |

`prom-sm-quarkus.yaml` is a starting point. Replace every `changeme`:

| Field | Value |
|---|---|
| `metadata.name` | a name for this application, such as `designer` |
| `spec.endpoints[0].path` | the metrics path, see below |
| `spec.namespaceSelector.matchNames[0]` | the namespace of the application |
| `spec.selector.matchLabels` | a label that selects only its Service |

The path assumes the application serves under its own root, which is what a Quarkus
service with a non-empty `quarkus.http.root-path` does. For an application with the root
path `/designer`, the metrics path is `/designer/q/metrics`. An application at the server
root uses `/q/metrics` instead.

The port name `http` must match the port name on the Service, not the container port
number.

Check the result in Prometheus under Status, then Targets. A ServiceMonitor that selects
nothing shows no target at all, rather than a failing one. The `grafana-db-quarkus.yaml`
dashboard of this directory reads the series that it produces.

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-quarkus.yaml` | [Grafana.com dashboard 14370](https://grafana.com/grafana/dashboards/14370) |

## References

- [Quarkus, Micrometer metrics](https://quarkus.io/guides/micrometer)
- [Quarkus, SmallRye metrics](https://quarkus.io/guides/smallrye-metrics)
