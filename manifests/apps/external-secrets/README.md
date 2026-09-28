# External Secrets Operator Monitoring

PrometheusRule alerts and a Grafana dashboard for the External Secrets Operator.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough.

```yaml
resources:
  - <release>/apps/external-secrets
```

## Components

| File                                                | Description                                   |
|-----------------------------------------------------|-----------------------------------------------|
| `prom-sm-external-secrets.yaml`                     | ServiceMonitor for the controller Service     |
| `prom-sm-external-secrets-cert-controller.yaml`     | ServiceMonitor for the cert-controller Service |
| `prom-sm-external-secrets-webhook.yaml`             | ServiceMonitor for the webhook Service        |
| `prom-rule-external-secrets.yaml`                   | PrometheusRule alerts (three groups)          |
| `grafana-db-external-secrets.yaml`                  | GrafanaDashboard read from a URL              |

## Prerequisites

The three ServiceMonitors live in the `monitoring` namespace and select Services
in the `external-secrets` namespace. The chart creates no metrics Service by
default. In the External Secrets Operator Helm release (chart 2.8.0), set these
values:

```yaml
metrics:
  service:
    enabled: true
certController:
  metrics:
    service:
      enabled: true
webhook:
  metrics:
    service:
      enabled: true
serviceMonitor:
  enabled: false
```

`serviceMonitor.enabled=false` keeps the chart from creating its own monitors,
which duplicate the ones in this component. With `serviceMonitor.enabled=false`, the chart leaves the
`app.kubernetes.io/metrics` label off the cert-controller and webhook Services.
For that reason the selectors here match `app.kubernetes.io/name` alone.

The webhook metrics endpoint is a second port on the `external-secrets-webhook`
Service, not a separate Service. The port appears only with
`webhook.metrics.service.enabled=true`.

If the chart runs in another namespace, change the `namespaceSelector` in each
ServiceMonitor file.

The alerts in the `external-secrets-controller` group filter on
`service=~".*external-secrets.*"`. The official dashboard uses the same filter.
If your ServiceMonitor produces a different `service` label, adjust the group.

## Alert groups

| Group                          | Content                                                                          |
|--------------------------------|----------------------------------------------------------------------------------|
| `external-secrets-resources`   | Ready conditions of ExternalSecret, ClusterExternalSecret, PushSecret, SecretStore and ClusterSecretStore, plus slow reconciliation |
| `external-secrets-sync`        | Sync error ratio, provider API error ratio and absence of sync activity           |
| `external-secrets-controller`  | controller-runtime reconciliation errors, work queue depth and webhook 5xx answers |

## References

- [External Secrets Operator](https://external-secrets.io/)
- [External Secrets metrics](https://external-secrets.io/latest/api/metrics/)
- [kubebuilder metrics reference](https://book.kubebuilder.io/reference/metrics-reference.html)

## Rules sources

- <https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/main/charts/external-secrets-operator/templates/prometheusrule.yaml>
- <https://github.com/external-secrets/external-secrets/issues/2590>

## Dashboard Sources

| Dashboard          | Source                                                                                                     |
|--------------------|------------------------------------------------------------------------------------------------------------|
| External Secrets Operator | <https://github.com/external-secrets/external-secrets/blob/main/docs/snippets/dashboard.json> |

The dashboard carries its own `datasource` variable of type Prometheus. It needs
no `datasources:` mapping in the GrafanaDashboard resource.
