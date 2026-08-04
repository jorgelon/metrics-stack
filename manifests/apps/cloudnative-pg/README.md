# CloudNative-PG Monitoring

PodMonitors, PrometheusRules, and Grafana dashboard for the CloudNative-PG operator and PostgreSQL clusters.

## Components

| File                              | Description                                    |
|-----------------------------------|------------------------------------------------|
| `prom-pm-cloudnative-pg.yaml`     | PodMonitor for PostgreSQL cluster instances    |
| `prom-pm-cloudnative-pg-operator.yaml` | PodMonitor for the CNPG operator          |
| `prom-rule-cloudnative-pg.yaml`   | PrometheusRule alerts                          |
| `prom-amc-inhibit-cnpg.yaml`      | AlertmanagerConfig inhibit rules               |
| `grafana-db-cloudnative-pg.yaml`  | Grafana dashboard                              |
| `configmap-custom-metrics.yaml`   | Custom metrics configuration                   |

## Prerequisites

- CNPG operator must be deployed in the `cnpg-system` namespace.
- Disable the built-in PodMonitor in each PostgreSQL cluster to avoid duplicate metrics:

```yaml
spec:
  monitoring:
    enablePodMonitor: false
```

## Scrape Classes

The Prometheus instance has two scrape classes relevant to CNPG:

- **Instance PodMonitor** uses `scrapeClass: cnpg` — sets `cluster` from the pod label `cnpg.io/cluster`, so each PostgreSQL cluster is identified by its actual name (e.g. `cluster="cnpg-designer"`).
- **Operator PodMonitor** uses the default scrape class — adds `cluster="local"` since the operator manages all clusters.

## x509 Certificate Alerts

CloudNative-PG auto-renews its certificates. To suppress false positive expiry alerts from x509-certificate-exporter, patch the PrometheusRule:

```yaml
- alert: CertificateRenewal
  expr: (x509_cert_not_after - time()) < (28 * 86400)
        and x509_cert_not_after{secret_name!="cnpg-webhook-cert",subject_CN!="streaming_replica"}
- alert: CertificateExpiration
  expr: (x509_cert_not_after - time()) < (14 * 86400)
        and x509_cert_not_after{secret_name!="cnpg-webhook-cert",subject_CN!="streaming_replica"}
```

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-cloudnative-pg.yaml` | [cloudnative-pg/grafana-dashboards](https://github.com/cloudnative-pg/grafana-dashboards/blob/main/charts/cluster/grafana-dashboard.json) |

## References

- [CloudNative-PG monitoring](https://cloudnative-pg.io/documentation/current/monitoring/)
- [Default PrometheusRule](https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/refs/heads/main/docs/src/samples/monitoring/prometheusrule.yaml)
