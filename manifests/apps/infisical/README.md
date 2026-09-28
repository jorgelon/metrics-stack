# Infisical Monitoring

PodMonitor and PrometheusRule alerts for the Infisical secrets operator.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough.

```yaml
resources:
  - <release>/apps/infisical
```

## Components

| File                       | Description              |
|----------------------------|--------------------------|
| `prom-pm-infisical.yaml`   | PodMonitor               |
| `prom-rule-infisical.yaml` | PrometheusRule alerts    |

## References

- [Infisical](https://infisical.com/)
