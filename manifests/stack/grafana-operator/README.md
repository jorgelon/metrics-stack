# Grafana Operator

Official Grafana Operator manifests, version-pinned.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest. Name the version directory in the path.

```yaml
resources:
  - <release>/stack/grafana-operator/<version>
```

## Updating

Run the download script to fetch a new operator release:

```bash
./manifests/stack/grafana-operator/download_release.sh
```

Change the link in the stack kustomization.yaml

## References

- [Grafana Operator](https://grafana.github.io/grafana-operator/)
- [Grafana Operator releases](https://github.com/grafana/grafana-operator/releases)
