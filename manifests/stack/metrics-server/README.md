# Metrics Server

Official Metrics Server manifests, version-pinned. Provides basic CPU and memory metrics for `kubectl top` and the Horizontal Pod Autoscaler.

## How to deploy

This directory is a plain kustomization. It renders into the `kube-system` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest. Name the version directory in the path.

```yaml
resources:
  - <release>/stack/metrics-server/<version>
```

## Namespace

Metrics Server deploys entirely to `kube-system`, not `monitoring`. This is the official upstream manifest — Metrics Server is a Kubernetes API extension and must run in `kube-system`.

## Available Versions

| Version | Status  |
|---------|---------|
| v0.7.2  | Stable  |
| v0.8.0  | Stable  |
| v0.8.1  | Latest  |

## Updating

Run the download script to fetch a new release:

```bash
./manifests/stack/metrics-server/download.sh
```

## References

- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
