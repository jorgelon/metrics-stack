# examples

Manifests to copy into your own source. This directory is not a Kustomize component and
carries no `kustomization.yaml`. Nothing here is rendered by the release.

Each file holds `changeme` sentinels. Copy the file, replace every one of them, and list
the copy in your own kustomization.

| File | What it does |
|---|---|
| `gapi-httproute.yaml` | Exposes Grafana through a Gateway API gateway |
| `grafana-ds-loki.yaml` | Repoints the Loki datasource at another namespace |

## gapi-httproute.yaml

One `HTTPRoute` that sends every path of one hostname to the `grafana-k8s-service` Service
on port 3000. Replace four values: the Gateway name, its namespace, its listener
`sectionName`, and the hostname. List the copy under `resources:`.

You need the Gateway API CRDs and a controller that implements them. You also need a
`Gateway` with a listener that accepts your hostname, and DNS pointing at that gateway.
Set `GF_SERVER_ROOT_URL` to the same hostname, or Grafana builds broken redirect and asset
URLs.

## grafana-ds-loki.yaml

A strategic merge patch on the `GrafanaDatasource` named `loki`. The release directory
`apps/loki` ships that datasource pointing at `loki.loki.svc.cluster.local`. If your Loki
runs in another namespace, copy this patch, replace `changeme` with that namespace, and
list the copy under `patches:`.

You must keep `apps/loki` in `resources:`. A patch with no target fails the build.
