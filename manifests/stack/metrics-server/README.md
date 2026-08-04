# Metrics Server

Official Metrics Server manifests, version-pinned. Provides basic CPU and memory metrics for `kubectl top` and the Horizontal Pod Autoscaler.

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
