# Prometheus

Prometheus instance managed by the Prometheus Operator.

## Components

| File                              | Description                              |
|-----------------------------------|------------------------------------------|
| `prom-instance.yaml`              | Prometheus CRD instance                  |
| `k8s-sa-prometheus.yaml`          | ServiceAccount                           |
| `k8s-secret-prometheus-sa-token.yaml` | ServiceAccount token                 |
| `k8s-cr-prometheus.yaml`          | ClusterRole                              |
| `k8s-crb-prometheus.yaml`         | ClusterRoleBinding                       |
| `grafana-db-prometheus.yaml`      | Grafana dashboard for Prometheus itself  |

## Scrape Classes

The instance uses scrape classes to manage the `cluster` label consistently.

### Default Scrape Class

Conditionally adds `cluster="local"` only when the scraped metric does not already carry a `cluster` label:

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
