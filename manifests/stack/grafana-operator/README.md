# Grafana Operator

Official Grafana Operator manifests, version-pinned.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/grafana-operator
```

Do not reference a version directory directly. The `kustomization.yaml` of this directory
selects the active version.

## Updating

Run the download script to fetch a new operator release:

```bash
./manifests/stack/grafana-operator/download_release.sh
```

Then repoint the `resources:` entry of `kustomization.yaml` in this directory to the new
version directory.

The operator does not upgrade Grafana. The consumer chooses the Grafana version with an
`images:` entry, as the README of `stack/grafana` describes. Compare that version with the
default of the new operator release on the
[versioning page](https://grafana.github.io/grafana-operator/docs/versioning/).

## References

- [Grafana Operator](https://grafana.github.io/grafana-operator/)
- [Grafana Operator releases](https://github.com/grafana/grafana-operator/releases)
