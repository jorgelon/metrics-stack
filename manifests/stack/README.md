# Stack

The monitoring infrastructure itself: the Prometheus Operator, the Grafana Operator,
Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter and metrics-server.
Each vendored child selects its own active version in its own `kustomization.yaml`.

## How to deploy

This directory is a plain kustomization. It sets no namespace of its own. Each child sets
its own, so `metrics-server` renders into `kube-system` and every other child into
`monitoring`. List it under `resources:`. Read [DEPLOYING.md](../../DEPLOYING.md) for the
full walkthrough.

```yaml
resources:
  - <release>/stack
```

## Files

| File | Description |
|---|---|
| `kustomization.yaml` | Lists every child. It holds no version and no patch |
| `examples/` | Manifests that more than one child of the stack shares |

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy a file, replace every
`changeme`, and list the copy in your own kustomization.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `eso-css.yaml` | The Azure Key Vault store that the whole stack reads from | `instance/` | `resources:` |

### The Azure Key Vault store

`eso-css.yaml` is a `ClusterSecretStore` named `akv-metrics-stack`, scoped to the
`monitoring` namespace. It is the only file of the release that declares that store. Two
examples read from it by name, so copy it once and share it:

- `grafana/examples/eso-es-grafana-env-akv.yaml`, for Azure AD single sign-on.
- `alertmanager/examples/eso-es-msteams-webhook-url-azurekv.yaml`, for the Teams webhook.

Replace its `tenantId` and the host part of its `vaultUrl`. The store authenticates as a
service principal, and reads its credentials from the `akv-eso-creds` secret in the
`external-secrets` namespace. You need the External Secrets Operator with its CRDs, and an
Azure Key Vault.

`eso-css.yaml` is cluster-scoped. Kustomize does not know the scope of a custom resource,
so a `namespace:` in the kustomization that lists it writes a namespace into the object.
Set no `namespace:` there.

## References

- [External Secrets Operator: Azure Key Vault](https://external-secrets.io/latest/provider/azure-key-vault/)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [Grafana Operator](https://grafana.github.io/grafana-operator/)
