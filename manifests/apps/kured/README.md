# Kured Monitoring

PodMonitor and PrometheusRule alerts for Kured (Kubernetes Reboot Daemon).

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough.

```yaml
resources:
  - <release>/apps/kured
```

## Components

| File                   | Description              |
|------------------------|--------------------------|
| `prom-pm-kured.yaml`   | PodMonitor               |
| `prom-rule-kured.yaml` | PrometheusRule alerts    |

## References

- [Kured](https://kured.dev/)
- [Kured metrics](https://kured.dev/docs/operation/)
