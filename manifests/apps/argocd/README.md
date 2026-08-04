# ArgoCD Monitoring

ServiceMonitors and Grafana dashboard for ArgoCD.

## Components

| File                                              | Description                                  |
|---------------------------------------------------|----------------------------------------------|
| `prom-sm-argocd-metrics.yaml`                     | Application controller metrics               |
| `prom-sm-argocd-server-metrics.yaml`              | API server metrics                           |
| `prom-sm-argocd-repo-server-metrics.yaml`         | Repo server metrics                          |
| `prom-sm-argocd-applicationset-controller-metrics.yaml` | ApplicationSet controller metrics    |
| `prom-sm-argocd-notifications-controller.yaml`    | Notifications controller metrics             |
| `prom-sm-argocd-dex-server.yaml`                  | Dex server metrics                           |
| `prom-sm-argocd-redis-haproxy-metrics.yaml`       | Redis HA proxy metrics                       |
| `grafana-db-argocd.yaml`                          | ArgoCD Grafana dashboard                     |
| `mixins/`                                         | ArgoCD monitoring mixin rules and dashboards |

## ArgoCD Sync Waves

Recommended deployment order for the metrics stack using ArgoCD sync waves:

| Wave | Components                                                                 |
|------|----------------------------------------------------------------------------|
| -5   | prometheus-operator, grafana-operator, Grafana PVC, external secretstore   |
| -3   | prometheus, external secret for AlertmanagerConfig                         |
| -2   | AlertmanagerConfig                                                         |
| -1   | alertmanager                                                               |
| 0    | Everything else (default)                                                  |

See [ArgoCD sync waves documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/).

## Dashboard Sources

| File | Source |
|------|--------|
| `grafana-db-argocd.yaml` | [ArgoCD official examples](https://github.com/argoproj/argo-cd/blob/master/examples/dashboard.json) |
| `mixins/` | [monitoring.mixins.dev — ArgoCD](https://monitoring.mixins.dev/argocd/) and [argo-cd-2](https://monitoring.mixins.dev/argo-cd-2/) |

## References

- [ArgoCD metrics](https://argo-cd.readthedocs.io/en/stable/operator-manual/metrics/)
- [monitoring.mixins.dev — ArgoCD](https://monitoring.mixins.dev/)
