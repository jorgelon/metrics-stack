# Metrics Server

Official Metrics Server manifests, version-pinned. Provides basic CPU and memory metrics for `kubectl top` and the Horizontal Pod Autoscaler.

## How to deploy

This directory is a plain kustomization. It renders into the `kube-system` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/metrics-server
```

Do not reference a version directory directly. It holds the upstream manifest only,
without the patch below. The `kustomization.yaml` of this directory selects the active
version.

## Files

| File | Description |
|---|---|
| `kustomization.yaml` | Selects the active version and applies the patch |
| `k8s-deploy-patch-args-metrics-server.yaml` | A JSON 6902 patch that adds `--kubelet-insecure-tls` |
| `v0.8.1/`, `v0.9.0/` | The vendored upstream manifests, one directory per version |
| `download.sh` | Downloads a new upstream version |

## The kubelet TLS patch

A kubeadm kubelet serves a self-signed certificate that no cluster CA signs.
Metrics Server rejects that certificate, so `kubectl top` returns no data. The patch adds
`--kubelet-insecure-tls`, which turns off the check. The patch appends to the `args`
list. A strategic merge patch replaces the whole list and drops the upstream flags.

## Namespace

Metrics Server deploys entirely to `kube-system`, not `monitoring`. This is the official upstream manifest — Metrics Server is a Kubernetes API extension and must run in `kube-system`.

## Available Versions

| Version | Status  |
|---------|---------|
| v0.8.1  | Vendored |
| v0.9.0  | Vendored |

## Updating

Run the download script to fetch a new release:

```bash
./manifests/stack/metrics-server/download.sh
```

Then repoint the `resources:` entry of `kustomization.yaml` to the new version directory.

## References

- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
