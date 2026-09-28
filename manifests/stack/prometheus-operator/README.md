# Prometheus Operator

Official Prometheus Operator manifests, version-pinned.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest. Name the version directory in the path.

```yaml
resources:
  - <release>/stack/prometheus-operator/<version>
```

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

## Patched arguments

The file `manifests/stack/kustomization.yaml` adds `--config-reloader-cpu-limit=0`
to the operator. By default the operator gives every `config-reloader` sidecar
a 10m CPU limit. An instance that declares its own sidecar resources still
gets that limit. A sidecar CPU request above 10m then makes the StatefulSet invalid.
The value `0` removes the limit. The Prometheus and the Alertmanager instances
of this repository declare a CPU request of 100m and 50m for their sidecar, so
they need this argument.

## ArgoCD Sync Wave

Deploy at wave `-5` — this must be running before Prometheus and Alertmanager instances are created.

## References

- [Prometheus Operator](https://prometheus-operator.dev/)
- [Prometheus Operator releases](https://github.com/prometheus-operator/prometheus-operator/releases)
