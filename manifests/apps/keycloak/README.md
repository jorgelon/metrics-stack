# Keycloak Monitoring

Grafana dashboards and a ServiceMonitor for Keycloak deployed via keycloak operator

## Components

| File                                         | Description                                                                                                             |
|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `prom-sm-keycloak.yaml`                      | ServiceMonitor for Keycloak (path `/metrics`, port `management`, scheme HTTPS, TLS skip verify)                        |
| `prom-pr-keycloak.yaml`                      | PrometheusRule: compat recording rule mapping `jvm_info_total` → `jvm_info` for Micrometer 1.14+ (disabled by default) |
| `grafana-db-keycloak-capacity-planning.yaml` | Dashboard: capacity planning                                                                                            |
| `grafana-db-keycloak-troubleshooting.yaml`   | Dashboard: troubleshooting                                                                                              |

## Prerequisites

### Keycloak

Enable metrics in Keycloak before deploying this configuration:

| Option                       | Type       | Default  | Description                                                                                    |
|------------------------------|------------|----------|------------------------------------------------------------------------------------------------|
| `metrics-enabled`            | build-time | `false`  | Exposes the `/metrics` endpoint. Must be `true`.                                               |
| `event-metrics-user-enabled` | runtime    | `false`  | Creates `keycloak_user_events_total` counter metrics from user events. Requires `metrics-enabled=true`. |
| `event-metrics-user-events`  | runtime    | all      | Comma-separated list of event types to collect. The capacity planning dashboard requires: `login,logout,code_to_token,refresh_token,client_login,token_exchange`. The troubleshooting dashboard does not use event metrics. |
| `event-metrics-user-tags`    | runtime    | `realm`  | Comma-separated label dimensions. Possible values: `realm`, `idp`, `clientId`. Both dashboards filter by `realm` only — the default is sufficient. Adding `idp` or `clientId` increases cardinality without benefit for these dashboards. |

### Grafana

Both dashboards use `GrafanaDashboard` resources from the Grafana Operator and require:

- A `Grafana` instance labeled `app.kubernetes.io/part-of: metrics-stack` (matched by `instanceSelector`)
- A Grafana datasource named `prometheus` (mapped to the `DS_PROMETHEUS` dashboard input)
- The dashboards are placed in the `keycloak` folder inside Grafana

## Dashboard Sources

| File                                         | Source                                                                                        |
|----------------------------------------------|-----------------------------------------------------------------------------------------------|
| `grafana-db-keycloak-capacity-planning.yaml` | [keycloak/keycloak-grafana-dashboard](https://github.com/keycloak/keycloak-grafana-dashboard) |
| `grafana-db-keycloak-troubleshooting.yaml`   | [keycloak/keycloak-grafana-dashboard](https://github.com/keycloak/keycloak-grafana-dashboard) |

## Links

<https://www.keycloak.org/observability/grafana-dashboards>
<https://www.keycloak.org/observability/keycloak-service-level-indicators>
<https://www.keycloak.org/observability/metrics-for-troubleshooting>
<https://www.keycloak.org/observability/event-metrics>
<https://www.keycloak.org/observability/configuration-metrics>
<https://www.keycloak.org/observability/metrics-for-troubleshooting>
<https://access.redhat.com/solutions/7120253>
