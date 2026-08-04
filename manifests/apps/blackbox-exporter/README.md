# Blackbox Exporter

HTTP endpoint monitoring using the Prometheus Blackbox Exporter.

## Components

| File                        | Description                                      |
|-----------------------------|--------------------------------------------------|
| `k8s-deploy-blacbox-exporter.yaml` | Blackbox Exporter Deployment              |
| `sa.yaml`                   | ServiceAccount                                   |
| `clusterRole.yaml`          | ClusterRole                                      |
| `clusterRoleBinding.yaml`   | ClusterRoleBinding                               |
| `service.yaml`              | Service                                          |
| `configmap.yaml`            | Blackbox Exporter configuration                  |
| `probehttp.yaml`            | Probe for HTTP endpoints                         |
| `probeIngressSkipcert.yaml` | Probe for Ingress endpoints (skip TLS verify)    |
| `dashboardhttp2xx.yaml`     | Grafana dashboard for HTTP 2xx checks            |

## Dashboard Sources

| File | Source |
|------|--------|
| `dashboardhttp2xx.yaml` | [Grafana.com dashboard 16124](https://grafana.com/grafana/dashboards/16124) |

## References

- [Prometheus Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)
- [Prometheus Operator — Probe CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.Probe)
