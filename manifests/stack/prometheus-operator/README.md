# Prometheus Operator

Official Prometheus Operator manifests, version-pinned.

## Available Versions

| Version | Status  |
|---------|---------|
| v0.82.0 | Stable  |
| v0.85.0 | Stable  |
| v0.90.0 | Latest  |

## Updating

Run the download script to fetch a new operator release:

```bash
./manifests/stack/prometheus-operator/download_releases.sh
```

## ArgoCD Sync Wave

Deploy at wave `-5` — this must be running before Prometheus and Alertmanager instances are created.

## References

- [Prometheus Operator](https://prometheus-operator.dev/)
- [Prometheus Operator releases](https://github.com/prometheus-operator/prometheus-operator/releases)
