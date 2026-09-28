# Prometheus

Prometheus instance managed by the Prometheus Operator.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/prometheus
```

## Files

| File                              | Description                              |
|-----------------------------------|------------------------------------------|
| `prom-instance.yaml`              | Prometheus CRD instance                  |
| `k8s-sa-prometheus.yaml`          | ServiceAccount                           |
| `k8s-secret-prometheus-sa-token.yaml` | ServiceAccount token                 |
| `k8s-cr-prometheus.yaml`          | ClusterRole                              |
| `k8s-crb-prometheus.yaml`         | ClusterRoleBinding                       |
| `grafana-db-prometheus.yaml`      | Grafana dashboard for Prometheus itself  |

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy a file, replace every
`changeme`, and list the copy in your own kustomization. A patch goes into your
`overlays/` folder, and a resource goes into your `instance/` folder.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `prom-instance.yaml` | One replica keeping 7 days on a 100Gi volume, with both containers sized | `overlays/` | `patches:` |

```yaml
resources:
  - <release>/stack
patches:
  - path: overlays/prom-instance.yaml
```

The base declares no replicas, no retention, no storage and no container size. Without a
patch like the example, the operator runs one replica writing to an `emptyDir` with the
default retention, and every restart loses the data. This is the simple shape: one
replica, local disk, no high availability, no long term storage and no remote write.

Replace `storageClassName: changeme` with a storage class of your cluster. Keep `stack`
under `resources:`, because a patch with no target fails the build. 100Gi holds 7 days on
a mid-sized cluster. The operator does not resize an existing claim, so a later change
needs a new claim, or the StatefulSet deleted with `--cascade=orphan`.

Two alternatives exist. One is two replicas for high availability, where each replica
keeps its own copy on its own volume and Alertmanager deduplicates the alerts. The other
is remote write to a long term store, such as Thanos or Mimir, where local retention drops
to a few hours. This release ships no example for either one yet.

## Sizing

`prom-instance.yaml` sizes neither container. The prometheus container tracks the number of
series the cluster produces. No two clusters agree on that, so the size belongs in the
consuming kustomization. `examples/prom-instance.yaml` carries both sizes, in the same
patch as the storage:

```yaml
# overlays/prom-instance.yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
spec:
  resources:
    requests:
      cpu: 500m
      memory: 4Gi
    limits:
      memory: 4Gi
  containers:
    - name: config-reloader
      resources:
        requests:
          cpu: 100m
          memory: 100Mi
        limits:
          memory: 100Mi
```

Each memory request equals its limit, so the pod lands in the Guaranteed QoS class for
memory. Neither container declares a CPU limit. 500m CPU and 4Gi of memory is a starting
point. Raise it from the memory that the container actually uses.

## Scrape Classes

The instance uses scrape classes to manage the `cluster` label consistently.

### Default Scrape Class

If the scraped metric does not already carry a `cluster` label, this adds `cluster="local"`:

```yaml
scrapeClasses:
  - name: default-cluster
    default: true
    relabelings:
      - action: replace
        targetLabel: cluster
        replacement: "local"
        regex: ^$
        sourceLabels: [cluster]
```

### CNPG Scrape Class

Sets `cluster` from the pod label `cnpg.io/cluster`, so each PostgreSQL cluster is identified by its actual name instead of `"local"`:

```yaml
  - name: cnpg
    relabelings:
      - sourceLabels: [__meta_kubernetes_pod_label_cnpg_io_cluster]
        targetLabel: cluster
        action: replace
```

The CNPG instance PodMonitor sets `scrapeClass: cnpg`. The CNPG operator PodMonitor uses the default scrape class.

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-prometheus.yaml` | [Grafana.com dashboard 19105](https://grafana.com/grafana/dashboards/19105) |

## RBAC References

- [Prometheus RBAC setup](https://raw.githubusercontent.com/prometheus/prometheus/refs/heads/main/documentation/examples/rbac-setup.yml)
- [Prometheus Operator RBAC](https://prometheus-operator.dev/docs/platform/rbac/)
- [kube-prometheus ClusterRole examples](https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests)
- [Prometheus storage](https://prometheus.io/docs/prometheus/latest/storage/)
