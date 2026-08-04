# Grafana

Grafana instance managed by the Grafana Operator, with a Prometheus datasource pre-configured.

## Components

| File                        | Description                              |
|-----------------------------|------------------------------------------|
| `grafana-instance.yaml`     | Grafana CRD instance                     |
| `grafana-ds-prometheus.yaml`| Grafana datasource pointing to Prometheus|

## Prerequisites

Create a PVC named `grafana` in the `monitoring` namespace before deploying:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
  namespace: monitoring
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
```

## Configuration via Environment Variables

The Grafana instance loads a Secret named `grafana-env` as environment variables. Use this to override any Grafana configuration option:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-env
  namespace: monitoring
stringData:
  GF_AUTH_ANONYMOUS_ENABLED: "true"
```

See the [Grafana environment variable docs](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#override-configuration-with-environment-variables) for available options.

## Automatic Restart on Config Change

The Grafana deployment is annotated for [Stakater Reloader](https://github.com/stakater/Reloader). If the `grafana-env` Secret changes, Grafana restarts automatically to pick up the new configuration.

## Limitations

- Not configured for more than 1 replica (Grafana OSS limitation with SQLite).
- Use Day 2 overlays to add resource limits or persistent storage customizations.
