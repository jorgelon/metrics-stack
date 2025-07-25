# Notes about applications

## CNPG

- In order to avoid duplicate metrics, disable the podmonitor in your clusters

```yaml
spec:
  monitoring:
    enablePodMonitor: false
```

- It assumes the operator is deployed in the cnpg-system namespace

- The default rules are located here

<https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/refs/heads/main/docs/src/samples/monitoring/prometheusrule.yaml>

## Quarkus

This stack does not create a service monitor or pod monitor because I can't standardize that. Create them outside this repo.

## Loki

Enabling Loki creates a grafana datasource using <http://loki.loki.svc.cluster.local:3100> as url.

The dashboards for loki infra will be created using <https://github.com/grafana/loki/tree/main/production/loki-mixin-compiled>

## Keycloak

### Requirements

- the prometheus pod/service monitor is not included here

- enable keycloak builting metrics (metrics-enabled=true)

- enable keycloak event metrics (event-metrics-user-enabled=true)

- define list of events to be collected (event-metrics-user-events)

### Dashboards sources

- keycloak-grafana-dashboard

<https://github.com/keycloak/keycloak-grafana-dashboard>

- grafana.com id 14390

<https://access.redhat.com/solutions/7120253>
