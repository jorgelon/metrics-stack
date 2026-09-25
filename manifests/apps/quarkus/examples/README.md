# examples

Manifests to copy into your own source. This directory is not a Kustomize component and
carries no `kustomization.yaml`. Nothing here is rendered by the release.

| File | What it does |
|---|---|
| `prom-sm-quarkus.yaml` | Scrapes one Quarkus application |

## prom-sm-quarkus.yaml

Quarkus applications do not share a layout, so the release ships no scrape target of its
own. This file is a starting point. Copy it, replace every `changeme`, and list the copy
under `resources:`.

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
nothing shows no target at all, rather than a failing one.

The `grafana-db-quarkus.yaml` dashboard in the parent directory reads the series this
produces.
