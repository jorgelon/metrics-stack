# Karma

Karma is a multi-Alertmanager dashboard for browsing and filtering alerts.

## Files

| File                    | Description       |
|-------------------------|-------------------|
| `k8s-deploy-karma.yaml` | Karma Deployment  |
| `k8s-svc-karma.yaml`    | Karma Service     |

## Examples

[`examples/`](examples/README.md) holds manifests to copy into your own source. They are
examples, not components, so nothing references them:

| File | What it does |
|---|---|
| `gapi-httproute.yaml` | Exposes Karma through a Gateway API gateway |
| `k8s-cm-karma-config.yaml` | Opens Karma on the active alerts that go to Microsoft Teams |

## Configuration

Karma connects to the Alertmanager instance in the `monitoring` namespace on its own. The
base creates no route, so copy the example above, or write your own Ingress.

## References

- [Karma](https://github.com/prymitive/karma)
