# Prometheus

Prometheus instance managed by the Prometheus Operator.

## Files

| File                              | Description                              |
|-----------------------------------|------------------------------------------|
| `prom-instance.yaml`              | Prometheus CRD instance                  |
| `k8s-sa-prometheus.yaml`          | ServiceAccount                           |
| `k8s-secret-prometheus-sa-token.yaml` | ServiceAccount token                 |
| `k8s-cr-prometheus.yaml`          | ClusterRole                              |
| `k8s-crb-prometheus.yaml`         | ClusterRoleBinding                       |
| `grafana-db-prometheus.yaml`      | Grafana dashboard for Prometheus itself  |

## Components

| Component | Adds |
|---|---|
| [`single-pvc`](single-pvc/README.md) | One replica keeping 7 days on a 100Gi volume |

```yaml
resources:
  - <release>/stack
components:
  - <release>/stack/prometheus/single-pvc
```

The base declares no replicas, no retention and no storage. Without the component the
operator runs one replica writing to an `emptyDir`, and every restart loses the data. You
must overlay the `changeme` storage class the component carries. Read its README.

Two alternatives exist. One is two replicas for high availability. The other is remote
write to a long term store, such as Thanos or Mimir. This release ships no component for
either one yet.

## Sizing

`prom-instance.yaml` sizes the config-reloader sidecar. Its memory request equals its
limit, and it declares no CPU limit.

The prometheus container itself is not sized anywhere. It tracks the number of series the
cluster produces, and no two clusters agree on that, so set it in the consuming
kustomization:

```yaml
# overlays/prom-instance.yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
spec:
  resources:
    requests:
      cpu: 200m
    limits:
      memory: 3Gi
```

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
